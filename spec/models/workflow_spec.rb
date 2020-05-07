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

  describe "When filter by admin tags" do
    let(:admin_user) { AdminUser.current_admin_user = create(:admin_user) }

    before :each do
      admin_user.tags.clear
    end

    it "allow workflow creation only with person valid admin tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:alt_full_person_tagging).person

      admin_user.tags << person1.tags.first

      issue1 = create(:basic_issue, person: person1)
      issue2 = create(:basic_issue, person: person2)

      expect do
        workflow = Workflow.new(issue: Issue.find(issue1.id))
        workflow.workflow_type = 'onboarding'
        workflow.scope = 'robot'
        workflow.save!
      end.to change { Workflow.count }.by(1)

      expect { Issue.find(issue2.id) }.to raise_error(ActiveRecord::RecordNotFound)

      admin_user.tags << person2.tags.first

      expect do
        workflow = Workflow.new(issue: Issue.find(issue1.id))
        workflow.workflow_type = 'onboarding'
        workflow.scope = 'robot'
        workflow.save!
      end.to change { Workflow.count }.by(1)

      expect do
        workflow = Workflow.new(issue: Issue.find(issue2.id))
        workflow.workflow_type = 'onboarding'
        workflow.scope = 'robot'
        workflow.save!
      end.to change { Workflow.count }.by(1)
    end

    it "allow workflow creation with person tags if admin has no tags" do
      person = create(:full_person_tagging).person
      issue = create(:basic_issue, person: person)

      expect do
        workflow = Workflow.new(issue: Issue.find(issue.id))
        workflow.workflow_type = 'onboarding'
        workflow.scope = 'robot'
        workflow.save!
      end.to change { Workflow.count }.by(1)
    end

    it "allow workflow creation without person tags if admin has no tags" do
      person = create(:empty_person)
      issue = create(:basic_issue, person: person)

      expect do
        workflow = Workflow.new(issue: Issue.find(issue.id))
        workflow.workflow_type = 'onboarding'
        workflow.scope = 'robot'
        workflow.save!
      end.to change { Workflow.count }.by(1)
    end

    it "allow workflow creation without person tags if admin has tags" do
      person = create(:full_person_tagging).person
      issue = create(:basic_issue, person: person)

      admin_user.tags << person.tags.first

      expect do
        workflow = Workflow.new(issue: Issue.find(issue.id))
        workflow.workflow_type = 'onboarding'
        workflow.scope = 'robot'
        workflow.save!
      end.to change { Workflow.count }.by(1)
    end

    it "Update a workflow with person tags if admin has tags" do
      workflow1, workflow2, workflow3, workflow4 = setup_for_admin_tags_spec
      person1 = workflow1.issue.person
      person3 = workflow3.issue.person

      admin_user.tags << person1.tags.first

      workflow = Workflow.find(workflow1.id)
      workflow.workflow_type = 'risk_check'
      workflow.scope = 'admin'
      workflow.save!

      workflow = Workflow.find(workflow2.id)
      workflow.workflow_type = 'risk_check'
      workflow.scope = 'admin'
      workflow.save!

      expect { Workflow.find(workflow3.id) }.to raise_error(ActiveRecord::RecordNotFound)

      workflow = Workflow.find(workflow4.id)
      workflow.workflow_type = 'risk_check'
      workflow.scope = 'admin'
      workflow.save!

      admin_user.tags << person3.tags.first

      workflow = Workflow.find(workflow3.id)
      workflow.workflow_type = 'risk_check'
      workflow.scope = 'admin'
      workflow.save!
    end

    it "Destroy a task with person tags if admin has tags" do
      workflow1, workflow2, workflow3, workflow4 = setup_for_admin_tags_spec
      person1 = workflow1.issue.person
      person3 = workflow3.issue.person

      admin_user.tags << person1.tags.first

      expect(Workflow.find(workflow1.id).destroy).to be_truthy
      expect(Workflow.find(workflow2.id).destroy).to be_truthy
      expect { Workflow.find(workflow3.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(Workflow.find(workflow4.id).destroy).to be_truthy

      admin_user.tags << person3.tags.first

      expect(Workflow.find(workflow3.id).destroy).to be_truthy
    end

    it "show workflow with admin user active tags" do
      workflow1, workflow2, workflow3, workflow4 = setup_for_admin_tags_spec
      person1 = workflow1.issue.person
      person3 = workflow3.issue.person

      expect(Workflow.find(workflow1.id)).to_not be_nil
      expect(Workflow.find(workflow2.id)).to_not be_nil
      expect(Workflow.find(workflow3.id)).to_not be_nil
      expect(Workflow.find(workflow4.id)).to_not be_nil

      admin_user.tags << person1.tags.first

      expect(Workflow.find(workflow1.id)).to_not be_nil
      expect(Workflow.find(workflow2.id)).to_not be_nil
      expect { Workflow.find(workflow3.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(Workflow.find(workflow4.id)).to_not be_nil

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first

      expect { Workflow.find(workflow1.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(Workflow.find(workflow2.id)).to_not be_nil
      expect(Workflow.find(workflow3.id)).to_not be_nil
      expect(Workflow.find(workflow4.id)).to_not be_nil

      admin_user.tags << person1.tags.first

      expect(Workflow.find(workflow1.id)).to_not be_nil
      expect(Workflow.find(workflow2.id)).to_not be_nil
      expect(Workflow.find(workflow3.id)).to_not be_nil
      expect(Workflow.find(workflow4.id)).to_not be_nil
    end

    it "index workflow with admin user active tags" do
      workflow1, workflow2, workflow3, workflow4 = setup_for_admin_tags_spec
      person1 = workflow1.issue.person
      person3 = workflow3.issue.person

      workflows = Workflow.all
      expect(workflows.count).to eq(4)
      expect(workflows[0].id).to eq(workflow1.id)
      expect(workflows[1].id).to eq(workflow2.id)
      expect(workflows[2].id).to eq(workflow3.id)
      expect(workflows[3].id).to eq(workflow4.id)

      admin_user.tags << person1.tags.first

      workflows = Workflow.all
      expect(workflows.count).to eq(3)
      expect(workflows[0].id).to eq(workflow1.id)
      expect(workflows[1].id).to eq(workflow2.id)
      expect(workflows[2].id).to eq(workflow4.id)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first

      workflows = Workflow.all
      expect(workflows.count).to eq(3)
      expect(workflows[0].id).to eq(workflow2.id)
      expect(workflows[1].id).to eq(workflow3.id)
      expect(workflows[2].id).to eq(workflow4.id)

      admin_user.tags << person1.tags.first

      workflows = Workflow.all
      expect(workflows.count).to eq(4)
      expect(workflows[0].id).to eq(workflow1.id)
      expect(workflows[1].id).to eq(workflow2.id)
      expect(workflows[2].id).to eq(workflow3.id)
      expect(workflows[3].id).to eq(workflow4.id)
    end

    def setup_for_admin_tags_spec
      person1 = create(:full_person_tagging).person
      person2 = create(:empty_person)
      person3 = create(:alt_full_person_tagging).person
      person4 = create(:empty_person)
      person4.tags << person1.tags.first
      person4.tags << person3.tags.first

      issue1 = create(:basic_issue, person: person1)
      issue2 = create(:basic_issue, person: person2)
      issue3 = create(:basic_issue, person: person3)
      issue4 = create(:basic_issue, person: person4)

      workflow1 = create(:basic_workflow, issue: issue1)
      workflow2 = create(:basic_workflow, issue: issue2)
      workflow3 = create(:basic_workflow, issue: issue3)
      workflow4 = create(:basic_workflow, issue: issue4)

      [workflow1, workflow2, workflow3, workflow4]
    end
  end
end
