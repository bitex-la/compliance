require 'rails_helper'

RSpec.describe Workflow, type: :model do 
  let(:invalid_workflow) { described_class.new }
  let(:basic_workflow) { create(:basic_workflow) }

  it 'is not valid without an issue, scope or type' do
    expect(invalid_workflow).to_not be_valid
    expect(invalid_workflow.errors[:issue]).to eq ["must exist"]
    expect(invalid_workflow.errors[:scope]).to eq ["is not included in the list"]
    expect(invalid_workflow.errors[:workflow_type]).to eq ["can't be blank"]
  end

  it 'is valid with an issue, scope and type' do
    expect(basic_workflow).to be_valid
  end

  it 'deletes workflow removes all tasks' do
    task = create(:basic_task)
    expect(Task.count).to eq(1)
    workflow = task.workflow.reload
    workflow.destroy!
    expect(Task.count).to eq(0)
  end

  it 'completness ratio should be 0 if tasks are not performed' do
    task = create(:basic_task)
    workflow = task.workflow.reload
    expect(workflow.completness_ratio).to eq 0
  end

  it 'completness ratio should be 100 if tasks are performed' do
    task = create(:basic_task)
    workflow = task.workflow.reload
    task.start!
    task.update!(output: 'all ok!')
    task.finish!
    expect(workflow.reload.completness_ratio).to eq 100
    expect(workflow.all_tasks_performed?).to be_truthy
  end

  describe 'when transitioning' do 
    let(:admin_user) { create(:admin_user) }
    let(:other_admin_user) { create(:other_admin_user) }

    before :each do 
      AdminUser.current_admin_user = admin_user 
    end

    it 'defaults to new' do
      expect(basic_workflow).to have_state(:new)
    end

    it 'goes from new to started on start' do
      expect(basic_workflow)
        .to transition_from(:new).to(:started).on_event(:start)
    end

    it 'goes from started to failed on fail' do
      expect(basic_workflow)
        .to transition_from(:started).to(:failed).on_event(:fail)
    end

    %i(new started).each do |state|
      it "goes from #{state} to dismissed on dismiss" do
        expect(basic_workflow)
          .to transition_from(state).to(:dismissed).on_event(:dismiss)
      end
    end

    it 'cannot mark a workflow as performed if tasks are pending' do
      3.times do 
        create(:basic_task, workflow: basic_workflow)
      end

      basic_workflow.reload.tasks.first.start!
      expect(basic_workflow).to have_state(:started)
      basic_workflow.tasks.first.update!(output: 'all ok!')
      basic_workflow.tasks.first.finish!
      expect(basic_workflow).to have_state(:started)

      expect { basic_workflow.reload.finish! }.to raise_error(AASM::InvalidTransition,
        "Event 'finish' cannot transition from 'started'. Failed callback(s): [:all_task_in_final_state?].")

      basic_workflow.tasks[1..-1]
        .each {|task| task.start!; task.update!(output: 'all clear!') ; task.finish!}

      basic_workflow.reload.finish!
      expect(basic_workflow).to have_state(:performed)   
    end

    it 'if workflow is done but has open observations, issue remains observed' do
      2.times do 
        create(:basic_task, workflow: basic_workflow)
      end

      issue = basic_workflow.issue

      robot_observation = create(:robot_observation, issue: issue)
      client_observation = create(:observation, issue: issue)

      basic_workflow.reload.tasks
        .each { |task| task.start!; task.update!(output: 'all clear!'); task.finish! }

      expect(issue.reload).to have_state(:observed)
      expect(basic_workflow).to have_state(:started)
    end

    it 'does not go to failed if any of tasks fails and has zero retries available' do
      3.times do 
        create(:basic_task, workflow: basic_workflow)
      end
      basic_workflow.reload.tasks.each {|task| task.start!}
      expect(basic_workflow).to have_state(:started)

      basic_workflow.tasks.each do |task|
        expect(task.can_retry?).to be_truthy
      end

      4.times do 
        basic_workflow.tasks.each {|task| task.failure!}
      end

      basic_workflow.tasks.each do |task|
        expect(task.current_retries).to eq 3
        expect(task).to have_state(:failed)
      end
      expect(basic_workflow).to have_state(:started)
    end

    it 'lock issue when workflow starts and unlock on finish' do
      3.times do 
        create(:basic_task, workflow: basic_workflow)
      end

      issue = basic_workflow.issue

      expect(issue.locked).to be false
      expect(issue.lock_admin_user).to be nil
      expect(issue.lock_expiration).to be nil

      basic_workflow.reload.tasks.each {|task| task.start!}

      expect(basic_workflow).to have_state(:started)

      issue.reload    
      expect(issue.locked).to be true
      expect(issue.lock_admin_user).to eq admin_user
      expect(issue.lock_expiration).to be nil

      basic_workflow.tasks.each {|task| task.update!(output: 'all clear!') ; task.finish!}

      basic_workflow.reload.finish!

      issue.reload
      expect(issue.locked).to be false
      expect(issue.lock_admin_user).to be nil
      expect(issue.lock_expiration).to be nil
    end

    it 'cannot starts a workflow if the issue is locked by another user' do
      issue = basic_workflow.issue
      expect(issue.lock_issue!).to be true

      AdminUser.current_admin_user = other_admin_user

      create(:basic_task, workflow: basic_workflow)

      expect { basic_workflow.reload.tasks.first.start! }.to raise_error(AASM::InvalidTransition,
        "Event 'start' cannot transition from 'new'. Failed callback(s): [:lock_issue!].")

      AdminUser.current_admin_user = admin_user

      expect(issue.unlock_issue!).to be true

      AdminUser.current_admin_user = other_admin_user

      basic_workflow.reload.tasks.first.start!

      expect(basic_workflow).to have_state(:started)
    end
  end
end
