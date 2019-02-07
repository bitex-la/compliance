require 'rails_helper'
require 'json'

describe Workflow do
  it_behaves_like 'jsonapi show and index',
    :workflows,
    :basic_workflow,
    :admin_risk_check_workflow,
    {scope_eq: 1},
    'scope',
    'issue'

  describe 'creating a new workflow' do
    it 'responds with an Unprocessable Entity when body is empty' do
      api_request :post, "/workflows", {}, 422
    end

    it 'forwards validation errors' do
      api_request :post, "/workflows", {
        type: 'workflows',
        attributes: {
          scope: 'client'
        }
      }, 422
    end

    it 'creates a new workflow' do
      issue = create(:basic_issue)

      expect do
        api_create('/workflows', {
          type: 'workflows',
          attributes: {
            workflow_kind_code: 'onboarding'
          },
          relationships: {
            issue: {data:{id: issue.id, type: 'issues'}}
          }
        })
      end.to change{ Workflow.count }.by 1

      assert_logging(Workflow.last, :create_entity, 1)
      workflow = Workflow.find(api_response.data.id)

      api_get("/workflows/#{workflow.id}")

      api_response.data.relationships.issue
        .data.id.to_i.should == issue.id 

      api_response.included.select{|o| o.type == 'issues'}
        .map(&:id).should == [issue.id.to_s]
    end
  end

  describe 'destroying a workflow' do
    it 'allow to destroy a workflow' do
      workflow = create(:basic_workflow)

      api_destroy "/workflows/#{workflow.id}", 204
      
      response.body.should be_blank

      api_get "/workflows/#{workflow.id}", {}, 404
    end
  end

  describe 'updating a workflow' do
    it 'can update workflow attributes' do
      workflow = create(:basic_workflow)

      api_update "/workflows/#{workflow.id}", {
        type: 'workflows',
        attributes: {scope: 'admin', workflow_kind_code: 'risk_check'}
      }

      api_response.data.attributes.scope.should == 'admin'
      api_response.data.attributes.workflow_kind_code.should == 'risk_check'

      api_response.data.relationships.issue
        .data.id.to_i.should == workflow.issue.id 

      api_response.included.select{|o| o.type == 'issues'}
        .map(&:id).should == [workflow.issue.id.to_s]
    end

    it 'cannot modify task state from update' do
      workflow = create(:basic_workflow)

      Workflow.aasm.states.map(&:name).each do |state|
        api_update "/workflows/#{workflow.id}", {
          type: 'workflows',
          attributes: {state: state}
        }

        api_response.data.attributes.state.should == 'new'
      end
    end

    describe 'when changing state' do
      it 'can start a workflow' do
        workflow = create(:basic_workflow)
        api_request :post, "/workflows/#{workflow.id}/start", {}, 200
      end

      it 'can finish a task from started state' do
        workflow = create(:basic_workflow)
        api_request :post, "/workflows/#{workflow.id}/finish", {}, 422
  
        api_request :post, "/workflows/#{workflow.id}/start", {}, 200
        api_request :post, "/workflows/#{workflow.id}/finish", {}, 200
      end

      it 'cannot finish a workflow from started if it has pending tasks' do
        workflow = create(:basic_workflow, 
          tasks: [create(:basic_task), create(:basic_task)])

        api_request :post, "/workflows/#{workflow.id}/start", {}, 200 
        api_request :post, "/workflows/#{workflow.id}/finish", {}, 422

        task_one = workflow.tasks.first
        task_two = workflow.tasks.second

        api_request :post, "/tasks/#{task_one.id}/start", {}, 200
        api_request :post, "/tasks/#{task_one.id}/finish", {}, 200
        api_request :post, "/workflows/#{workflow.id}/finish", {}, 422

        api_request :post, "/tasks/#{task_two.id}/start", {}, 200
        api_request :post, "/tasks/#{task_two.id}/finish", {}, 200
        
        expect(workflow.reload).to have_state(:performed)
      end

      it 'appear as finished if all tasks failed' do
        workflow = create(:basic_workflow)

        2.times do
          create(:basic_task, workflow: workflow, max_retries: 0)
        end

        api_request :post, "/workflows/#{workflow.id}/start", {}, 200 

        task_one = workflow.tasks.first
        task_two = workflow.tasks.second

        api_request :post, "/tasks/#{task_one.id}/start", {}, 200
        api_request :post, "/tasks/#{task_one.id}/fail", {}, 200
        api_request :post, "/tasks/#{task_two.id}/start", {}, 200
        api_request :post, "/tasks/#{task_two.id}/fail", {}, 200

        api_get "/workflows/#{workflow.id}", {}, 200

        api_response.data.attributes.state.should == 'failed'
      end
    end
  end
end