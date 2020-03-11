require 'rails_helper'
require 'json'

describe Task do 
  it_behaves_like 'jsonapi show and index',
    :tasks,
    :basic_task,
    :task_without_retries,
    {max_retries_eq: 0},
    'max_retries',
    'workflow'  

  it_behaves_like 'max people allowed request limit',
    :tasks,
    :basic_task

  describe 'creating a new task' do
    it 'responds with an Unprocessable Entity when body is empty' do
      api_request :post, "/tasks", {}, 422
    end

    it 'forwards validation errors' do
      api_request :post, "/tasks", {
        type: 'tasks',
        attributes: {
          max_retries: 1
        }
      }, 422
    end

    it 'creates a new task' do
      workflow = create(:basic_workflow)

      expect do
        api_create('/tasks', {
          type: 'tasks',
          attributes: {
            task_type: 'onboarding'
          },
          relationships: {
            workflow: {data:{id: workflow.id, type: 'workflows'}}
          }
        })
      end.to change{ Task.count }.by 1

      assert_logging(Task.last, :create_entity, 1)
      task = Task.find(api_response.data.id)

      api_get("/tasks/#{task.id}")

      api_response.data.relationships.workflow
        .data.id.to_i.should == workflow.id

      api_response.included.select{|o| o.type == 'workflows'}
        .map(&:id).should == [workflow.id.to_s]
    end
  end

  describe 'destroying a task' do
    it 'allow to destroy a task' do
      task = create(:basic_task)

      api_destroy "/tasks/#{task.id}", 204
      
      response.body.should be_blank

      api_get "/tasks/#{task.id}", {}, 404
    end
  end

  describe 'updating a task' do
    it 'can update task attributes' do
      task = create(:basic_task)

      api_update "/tasks/#{task.id}", {
        type: 'tasks',
        attributes: {current_retries: 2}
      }

      api_response.data.attributes.current_retries.should == 2

      api_response.data.relationships.workflow
        .data.id.to_i.should == task.workflow.id 
    end

    it 'cannot modify task state from update' do
      task = create(:basic_task)

      Task.aasm.states.map(&:name).each do |state|
        api_update "/tasks/#{task.id}", {
          type: 'tasks',
          attributes: {state: state}
        }

        api_response.data.attributes.state.should == 'new'
      end
    end
  end

  describe 'when changing state' do
    it "can start a task" do
      task = create(:basic_task)
      api_request :post, "/tasks/#{task.id}/start", {}, 200
    end

    it "can finish a task from started state" do
      task = create(:basic_task)
      api_request :post, "/tasks/#{task.id}/finish", {}, 422

      api_request :post, "/tasks/#{task.id}/start", {}, 200
      api_request :post, "/tasks/#{task.id}/finish", {}, 422

      api_update "/tasks/#{task.id}", {
        type: 'tasks',
        attributes: {output: 'All ok'}
      }

      api_request :post, "/tasks/#{task.id}/finish", {}, 200
    end

    it "can finish a task from retried state" do
      task = create(:basic_task)
      api_request :post, "/tasks/#{task.id}/finish", {}, 422

      api_request :post, "/tasks/#{task.id}/start", {}, 200
      api_request :post, "/tasks/#{task.id}/finish", {}, 422

      api_request :post, "/tasks/#{task.id}/failure", {}, 200
      api_request :post, "/tasks/#{task.id}/finish", {}, 422

      api_update "/tasks/#{task.id}", {
        type: 'tasks',
        attributes: {output: 'All ok'}
      }

      api_request :post, "/tasks/#{task.id}/finish", {}, 200
    end

    it "can fail from started state" do
      task = create(:basic_task)
      api_request :post, "/tasks/#{task.id}/fail", {}, 422
      
      api_request :post, "/tasks/#{task.id}/start", {}, 200
      api_request :post, "/tasks/#{task.id}/fail", {}, 200
    end

    it "can fail from retried state" do
      task = create(:basic_task)
      api_request :post, "/tasks/#{task.id}/fail", {}, 422
      
      api_request :post, "/tasks/#{task.id}/start", {}, 200
      api_request :post, "/tasks/#{task.id}/failure", {}, 200
      api_request :post, "/tasks/#{task.id}/fail", {}, 200
      api_request :post, "/tasks/#{task.id}/fail", {}, 200
    end
  end

  describe "When filter by admin tags" do
    let(:admin_user) { create(:admin_user) }

    before :each do
      admin_user.tags.clear
      admin_user.save!
    end

    it "allow task creation only with person valid admin tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:alt_full_person_tagging).person

      admin_user.tags << person1.tags.first
      admin_user.save!

      issue1 = create(:basic_issue, person: person1)
      issue2 = create(:basic_issue, person: person2)

      workflow1 = create(:basic_workflow, issue: issue1)
      workflow2 = create(:basic_workflow, issue: issue2)

      expect do
        api_create('/tasks',
          type: 'tasks',
          attributes: {
            task_type: 'onboarding'
          },
          relationships: {
            workflow: { data: { id: workflow1.id, type: 'workflows' } }
          })
      end.to change{ Task.count }.by 1

      task = Task.last
      expect(api_response.data.id).to eq(task.id.to_s)

      expect do
        api_create('/tasks', {
          type: 'tasks',
          attributes: {
            task_type: 'onboarding'
          },
          relationships: {
            workflow: { data: { id: workflow2.id, type: 'workflows' } }
          }
        }, 404)
      end.to change { Task.count }.by(0)

      expect(task).to eq(Task.last)

      admin_user.tags << person2.tags.first
      admin_user.save!

      expect do
        api_create('/tasks',
          type: 'tasks',
          attributes: {
            task_type: 'onboarding'
          },
          relationships: {
            workflow: { data: { id: workflow1.id, type: 'workflows' } }
          })
      end.to change{ Task.count }.by 1

      task = Task.last
      expect(api_response.data.id).to eq(task.id.to_s)

      expect do
        api_create('/tasks',
          type: 'tasks',
          attributes: {
            task_type: 'onboarding'
          },
          relationships: {
            workflow: { data: { id: workflow2.id, type: 'workflows' } }
          })
      end.to change{ Task.count }.by 1

      task = Task.last
      expect(api_response.data.id).to eq(task.id.to_s)
    end

    it "allow task creation with person tags if admin has no tags" do
      person = create(:full_person_tagging).person
      issue = create(:basic_issue, person: person)
      workflow = create(:basic_workflow, issue: issue)

      expect do
        api_create('/tasks',
          type: 'tasks',
          attributes: {
            task_type: 'onboarding'
          },
          relationships: {
            workflow: { data: { id: workflow.id, type: 'workflows' } }
          })
      end.to change{ Task.count }.by 1
    end

    it "allow task creation without person tags if admin has no tags" do
      person = create(:empty_person)
      issue = create(:basic_issue, person: person)
      workflow = create(:basic_workflow, issue: issue)

      expect do
        api_create('/tasks',
          type: 'tasks',
          attributes: {
            task_type: 'onboarding'
          },
          relationships: {
            workflow: { data: { id: workflow.id, type: 'workflows' } }
          })
      end.to change{ Task.count }.by 1
    end

    it "allow task creation without person tags if admin has tags" do
      person = create(:full_person_tagging).person
      issue = create(:basic_issue, person: person)

      admin_user.tags << person.tags.first
      admin_user.save!

      workflow = create(:basic_workflow, issue: issue)

      expect do
        api_create('/tasks',
          type: 'tasks',
          attributes: {
            task_type: 'onboarding'
          },
          relationships: {
            workflow: { data: { id: workflow.id, type: 'workflows' } }
          })
      end.to change{ Task.count }.by 1
    end

    it "Update a task with person tags if admin has tags" do
      task1, task2, task3, task4 = setup_for_admin_tags_spec
      person1 = task1.workflow.issue.person
      person3 = task3.workflow.issue.person

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_update "/tasks/#{task1.id}",
        type: 'tasks',
        attributes: { current_retries: 2 }

      api_update "/tasks/#{task2.id}",
        type: 'tasks',
        attributes: { current_retries: 2 }

      api_update "/tasks/#{task3.id}", {
        type: 'tasks',
        attributes: { current_retries: 2 }
      }, 404

      api_update "/tasks/#{task4.id}",
        type: 'tasks',
        attributes: { current_retries: 2 }

      admin_user.tags << person3.tags.first
      admin_user.save!

      api_update "/tasks/#{task3.id}",
        type: 'tasks',
        attributes: { current_retries: 2 }
    end

    it "Destroy a task with person tags if admin has tags" do
      task1, task2, task3, task4 = setup_for_admin_tags_spec
      person1 = task1.workflow.issue.person
      person3 = task3.workflow.issue.person

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_destroy "/tasks/#{task1.id}"
      response.body.should be_blank
      api_get "/tasks/#{task1.id}", {}, 404

      api_destroy "/tasks/#{task2.id}"
      response.body.should be_blank
      api_get "/tasks/#{task2.id}", {}, 404

      api_destroy "/tasks/#{task3.id}", 404

      api_destroy "/tasks/#{task4.id}"
      response.body.should be_blank
      api_get "/tasks/#{task4.id}", {}, 404

      admin_user.tags << person3.tags.first
      admin_user.save!

      api_destroy "/tasks/#{task3.id}"
      response.body.should be_blank
      api_get "/tasks/#{task3.id}", {}, 404
    end

    it "show task with admin user active tags" do
      task1, task2, task3, task4 = setup_for_admin_tags_spec
      person1 = task1.workflow.issue.person
      person3 = task3.workflow.issue.person

      api_get("/tasks/#{task1.id}")
      api_get("/tasks/#{task2.id}")
      api_get("/tasks/#{task3.id}")
      api_get("/tasks/#{task4.id}")

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/tasks/#{task1.id}")
      api_get("/tasks/#{task2.id}")
      api_get("/tasks/#{task3.id}", {}, 404)
      api_get("/tasks/#{task4.id}")

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      api_get("/tasks/#{task1.id}", {}, 404)
      api_get("/tasks/#{task2.id}")
      api_get("/tasks/#{task3.id}")
      api_get("/tasks/#{task4.id}")

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/tasks/#{task1.id}")
      api_get("/tasks/#{task2.id}")
      api_get("/tasks/#{task3.id}")
      api_get("/tasks/#{task4.id}")
    end

    it "index task with admin user active tags" do
      task1, task2, task3, task4 = setup_for_admin_tags_spec
      person1 = task1.workflow.issue.person
      person3 = task3.workflow.issue.person

      api_get("/tasks/")
      expect(api_response.meta.total_items).to eq(4)
      expect(api_response.data[0].id).to eq(task4.id.to_s)
      expect(api_response.data[1].id).to eq(task3.id.to_s)
      expect(api_response.data[2].id).to eq(task2.id.to_s)
      expect(api_response.data[3].id).to eq(task1.id.to_s)

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/tasks/")
      expect(api_response.meta.total_items).to eq(3)
      expect(api_response.data[0].id).to eq(task4.id.to_s)
      expect(api_response.data[1].id).to eq(task2.id.to_s)
      expect(api_response.data[2].id).to eq(task1.id.to_s)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      api_get("/tasks/")
      expect(api_response.meta.total_items).to eq(3)
      expect(api_response.data[0].id).to eq(task4.id.to_s)
      expect(api_response.data[1].id).to eq(task3.id.to_s)
      expect(api_response.data[2].id).to eq(task2.id.to_s)

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/tasks/")
      expect(api_response.meta.total_items).to eq(4)
      expect(api_response.data[0].id).to eq(task4.id.to_s)
      expect(api_response.data[1].id).to eq(task3.id.to_s)
      expect(api_response.data[2].id).to eq(task2.id.to_s)
      expect(api_response.data[3].id).to eq(task1.id.to_s)
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
