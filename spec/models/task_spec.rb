require 'rails_helper'

RSpec.describe Task, type: :model do 
  let(:invalid_task) { described_class.new }
  let(:basic_task) { create(:basic_task) }

  it 'is not valid without a workflow' do
    expect(invalid_task).to_not be_valid
    expect(invalid_task.errors[:workflow]).to eq ["must exist"]
    expect(invalid_task.errors[:task_type]).to eq ["can't be blank"]
  end

  it 'is valid with a workflow and type' do
    expect(basic_task).to be_valid
  end

  describe 'when transitioning' do 
    it 'defaults to new' do
      expect(basic_task).to have_state(:new)
    end

    it 'goes from new to started on start' do
      expect(basic_task)
        .to transition_from(:new).to(:started).on_event(:start)
    end

    %i(started retried).each do |state|
      it "goes from #{state} to performed on fail" do
        basic_task.start!
        expect(basic_task)
          .to transition_from(state).to(:failed).on_event(:fail)
      end
    end

    it "goes from started to performed on finish" do
      basic_task.start!
      expect do
        basic_task.finish!
      end.to raise_error AASM::InvalidTransition
      basic_task.update!(output: "Task performed at #{DateTime.now}")
      expect(basic_task.reload)
        .to transition_from(:started).to(:performed).on_event(:finish)
    end

    it "goes from retried to performed on finish" do
      expect(basic_task).to be_can_execute
      basic_task.start!
      basic_task.failure!
      expect do
        basic_task.finish!
      end.to raise_error AASM::InvalidTransition
      basic_task.update!(output: "Task performed at #{DateTime.now}")
      expect(basic_task.reload)
        .to transition_from(:retried).to(:performed).on_event(:finish)
    end

    it 'goes from failed to retried on retry' do
      expect do
        expect(basic_task)
        .to transition_from(:failed).to(:retried).on_event(:retry)
      end.to raise_error AASM::InvalidTransition
    end

    it 'goes to retry while do not reach max_retries' do
      basic_task.start!
      basic_task.failure!
      expect(basic_task.reload.current_retries).to eq 1

      2.times do |i|
        expect(basic_task.can_execute?).to be true
        basic_task.failure!
        expect(basic_task.reload.current_retries).to eq i + 2
      end

      basic_task.failure!
      expect(basic_task.can_execute?).to be false
      expect(basic_task.state).to eq("failed")
    end
  end

  describe "When filter by admin tags" do
    let(:admin_user) { AdminUser.current_admin_user = create(:admin_user) }

    before :each do
      admin_user.tags
    end

    it "allow task creation only with person valid admin tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:alt_full_person_tagging).person

      admin_user.tags << person1.tags.first

      issue1 = create(:basic_issue, person: person1)
      issue2 = create(:basic_issue, person: person2)

      workflow1 = create(:basic_workflow, issue: issue1)
      workflow2 = create(:basic_workflow, issue: issue2)

      expect do
        task = Task.new(workflow: Workflow.find(workflow1.id))
        task.task_type = 'onboarding'
        task.save!
      end.to change { Task.count }.by(1)

      expect { Workflow.find(workflow2.id) }.to raise_error(ActiveRecord::RecordNotFound)

      admin_user.tags << person2.tags.first

      expect do
        task = Task.new(workflow: Workflow.find(workflow1.id))
        task.task_type = 'onboarding'
        task.save!
      end.to change { Task.count }.by(1)

      expect do
        task = Task.new(workflow: Workflow.find(workflow2.id))
        task.task_type = 'onboarding'
        task.save!
      end.to change { Task.count }.by(1)
    end

    it "allow task creation with person tags if admin has no tags" do
      person = create(:full_person_tagging).person
      issue = create(:basic_issue, person: person)
      workflow = create(:basic_workflow, issue: issue)

      expect do
        task = Task.new(workflow: Workflow.find(workflow.id))
        task.task_type = 'onboarding'
        task.save!
      end.to change { Task.count }.by(1)
    end

    it "allow task creation without person tags if admin has no tags" do
      person = create(:empty_person)
      issue = create(:basic_issue, person: person)
      workflow = create(:basic_workflow, issue: issue)

      expect do
        task = Task.new(workflow: Workflow.find(workflow.id))
        task.task_type = 'onboarding'
        task.save!
      end.to change { Task.count }.by(1)
    end

    it "allow task creation without person tags if admin has tags" do
      person = create(:full_person_tagging).person
      issue = create(:basic_issue, person: person)

      admin_user.tags << person.tags.first

      workflow = create(:basic_workflow, issue: issue)

      expect do
        task = Task.new(workflow: Workflow.find(workflow.id))
        task.task_type = 'onboarding'
        task.save!
      end.to change { Task.count }.by(1)
    end

    it "Update a task with person tags if admin has tags" do
      task1, task2, task3, task4 = setup_for_admin_tags_spec
      person1 = task1.workflow.issue.person
      person3 = task3.workflow.issue.person

      admin_user.tags << person1.tags.first

      task = Task.find(task1.id)
      task.current_retries = 2
      task.save!

      task = Task.find(task2.id)
      task.current_retries = 2
      task.save!

      expect { Task.find(task3.id) }.to raise_error(ActiveRecord::RecordNotFound)

      task = Task.find(task4.id)
      task.current_retries = 2
      task.save!

      admin_user.tags << person3.tags.first

      task = Task.find(task3.id)
      task.current_retries = 2
      task.save!
    end

    it "Destroy a task with person tags if admin has tags" do
      task1, task2, task3, task4 = setup_for_admin_tags_spec
      person1 = task1.workflow.issue.person
      person3 = task3.workflow.issue.person

      admin_user.tags << person1.tags.first

      expect(Task.find(task1.id).destroy).to be_truthy
      expect(Task.find(task2.id).destroy).to be_truthy
      expect { Task.find(task3.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(Task.find(task4.id).destroy).to be_truthy

      admin_user.tags << person3.tags.first

      expect(Task.find(task3.id).destroy).to be_truthy
    end

    it "show task with admin user active tags" do
      task1, task2, task3, task4 = setup_for_admin_tags_spec
      person1 = task1.workflow.issue.person
      person3 = task3.workflow.issue.person

      expect(Task.find(task1.id)).to_not be_nil
      expect(Task.find(task2.id)).to_not be_nil
      expect(Task.find(task3.id)).to_not be_nil
      expect(Task.find(task4.id)).to_not be_nil

      admin_user.tags << person1.tags.first

      expect(Task.find(task1.id)).to_not be_nil
      expect(Task.find(task2.id)).to_not be_nil
      expect { Task.find(task3.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(Task.find(task4.id)).to_not be_nil

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first

      expect { Task.find(task1.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(Task.find(task2.id)).to_not be_nil
      expect(Task.find(task3.id)).to_not be_nil
      expect(Task.find(task4.id)).to_not be_nil

      admin_user.tags << person1.tags.first

      expect(Task.find(task1.id)).to_not be_nil
      expect(Task.find(task2.id)).to_not be_nil
      expect(Task.find(task3.id)).to_not be_nil
      expect(Task.find(task4.id)).to_not be_nil
    end

    it "index task with admin user active tags" do
      task1, task2, task3, task4 = setup_for_admin_tags_spec
      person1 = task1.workflow.issue.person
      person3 = task3.workflow.issue.person

      tasks = Task.all
      expect(tasks.count).to eq(4)
      expect(tasks[0].id).to eq(task1.id)
      expect(tasks[1].id).to eq(task2.id)
      expect(tasks[2].id).to eq(task3.id)
      expect(tasks[3].id).to eq(task4.id)

      admin_user.tags << person1.tags.first

      tasks = Task.all
      expect(tasks.count).to eq(3)
      expect(tasks[0].id).to eq(task1.id)
      expect(tasks[1].id).to eq(task2.id)
      expect(tasks[2].id).to eq(task4.id)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first

      tasks = Task.all
      expect(tasks.count).to eq(3)
      expect(tasks[0].id).to eq(task2.id)
      expect(tasks[1].id).to eq(task3.id)
      expect(tasks[2].id).to eq(task4.id)

      admin_user.tags << person1.tags.first

      tasks = Task.all
      expect(tasks.count).to eq(4)
      expect(tasks[0].id).to eq(task1.id)
      expect(tasks[1].id).to eq(task2.id)
      expect(tasks[2].id).to eq(task3.id)
      expect(tasks[3].id).to eq(task4.id)
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

      task1 = create(:basic_task, workflow: workflow1)
      task2 = create(:basic_task, workflow: workflow2)
      task3 = create(:basic_task, workflow: workflow3)
      task4 = create(:basic_task, workflow: workflow4)

      [task1, task2, task3, task4]
    end
  end
end
