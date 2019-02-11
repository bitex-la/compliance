require 'rails_helper'
require 'json'

describe Task do 
  it_behaves_like 'jsonapi show and index',
    :tasks,
    :basic_task,
    :task_without_retries,
    {max_retries_eq: 0},
    'max_retries',
    'task_type'  

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
      task_type = create(:generic_robot_task)

      expect do
        api_create('/tasks', {
          type: 'tasks',
          relationships: {
            workflow: {data:{id: workflow.id, type: 'workflows'}},
            task_type: {data:{id: task_type.id, type: 'task_types'}}
          }
        })
      end.to change{ Task.count }.by 1

      assert_logging(Task.last, :create_entity, 1)
      task = Task.find(api_response.data.id)

      api_get("/tasks/#{task.id}")

      api_response.data.relationships.workflow
        .data.id.to_i.should == workflow.id
      
      api_response.data.relationships.task_type
        .data.id.to_i.should == task_type.id  

      api_response.included.select{|o| o.type == 'workflows'}
        .map(&:id).should == [workflow.id.to_s]

      api_response.included.select{|o| o.type == 'task_types'}
        .map(&:id).should == [task_type.id.to_s]
    end
  end

  describe 'destroying a task' do
    it 'allow to destroy a task' do
      task = create(:basic_task, state: 'new')

      api_destroy "/tasks/#{task.id}", 204
      
      response.body.should be_blank

      api_get "/tasks/#{task.id}", {}, 404
    end
  end

  describe 'updating a task' do
    it 'can update task attributes' do
      task = create(:basic_task, state: 'new')

      api_update "/tasks/#{task.id}", {
        type: 'tasks',
        attributes: {current_retries: 2}
      }

      api_response.data.attributes.current_retries.should == 2

      api_response.data.relationships.workflow
        .data.id.to_i.should == task.workflow.id
      
      api_response.data.relationships.task_type
        .data.id.to_i.should == task.task_type.id  
    end

    it 'cannot modify task state from update' do
      task = create(:basic_task, state: 'new')

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
      task = create(:basic_task, state: 'new')
      api_request :post, "/tasks/#{task.id}/start", {}, 200
    end

    it "can finish a task from started state" do
      task = create(:basic_task, state: 'new')
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
      task = create(:basic_task, state: 'new')
      api_request :post, "/tasks/#{task.id}/finish", {}, 422

      api_request :post, "/tasks/#{task.id}/start", {}, 200
      api_request :post, "/tasks/#{task.id}/fail", {}, 200
      api_request :post, "/tasks/#{task.id}/finish", {}, 422

      api_request :post, "/tasks/#{task.id}/retry", {}, 200
      api_request :post, "/tasks/#{task.id}/finish", {}, 422

      api_update "/tasks/#{task.id}", {
        type: 'tasks',
        attributes: {output: 'All ok'}
      }

      api_request :post, "/tasks/#{task.id}/finish", {}, 200
    end

    it "can fail from started state" do
      task = create(:basic_task, state: 'new')
      api_request :post, "/tasks/#{task.id}/fail", {}, 422
      
      api_request :post, "/tasks/#{task.id}/start", {}, 200
      api_request :post, "/tasks/#{task.id}/fail", {}, 200
    end

    it "can fail from retried state" do
      task = create(:basic_task, state: 'new')
      api_request :post, "/tasks/#{task.id}/fail", {}, 422
      
      api_request :post, "/tasks/#{task.id}/start", {}, 200
      api_request :post, "/tasks/#{task.id}/fail", {}, 200
      api_request :post, "/tasks/#{task.id}/retry", {}, 200
      api_request :post, "/tasks/#{task.id}/fail", {}, 200
    end
  end
end