require 'rails_helper'

RSpec.describe Workflow, type: :model do 
  let(:invalid_workflow) { described_class.new }
  let(:basic_workflow) { create(:basic_workflow) }

  it 'is not valid without an issue' do
    expect(invalid_workflow).to_not be_valid
  end

  it 'is valid with an issue' do
    expect(basic_workflow).to be_valid
  end

  it 'deletes workflow removes all tasks' do
    task = create(:basic_task)
    expect(Task.count).to eq(1)
    workflow = task.workflow.reload
    workflow.destroy!
    expect(Task.count).to eq(0)
  end

  describe 'when transitioning' do 
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

    it 'can mark a workflow as performed even if tasks are pending' do
      3.times do 
        create(:basic_task, workflow: basic_workflow)
      end
      
      basic_workflow.reload.tasks.first.start!
      expect(basic_workflow).to have_state(:started)
      basic_workflow.tasks.first.update!(output: 'all ok!')
      basic_workflow.tasks.first.finish!
      expect(basic_workflow).to have_state(:started)

      basic_workflow.reload.finish!

      basic_workflow.tasks[1..-1]
        .each {|task| task.start!; task.update!(output: 'all clear!') ; task.finish!}

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
        .each {|task| task.start!; task.update!(output: 'all clear!') ; task.finish!}
      
      expect(issue.reload).to have_state(:observed)
      expect(basic_workflow).to have_state(:started)
    end

    it 'does not go to failed if any of tasks fails and has zero retries available' do
      3.times do 
        create(:basic_task, workflow: basic_workflow)
      end
      basic_workflow.reload.tasks.each {|task| task.start!; task.fail!}
      expect(basic_workflow).to have_state(:started)

      basic_workflow.tasks.each do |task|
        expect(task.can_retry?).to be_truthy
      end

      3.times do 
        basic_workflow.tasks.each {|task| task.retry!; task.fail!}
      end

      basic_workflow.tasks.each do |task|
        expect(task.current_retries).to eq 3
        expect(task).to have_state(:failed)
      end
      expect(basic_workflow).to have_state(:started)
    end
  end
end