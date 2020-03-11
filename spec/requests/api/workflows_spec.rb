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

  it_behaves_like 'max people allowed request limit',
    :workflows,
    :basic_workflow

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
            workflow_type: 'onboarding',
            scope: 'robot'
          },
          relationships: {
            issue: {data:{id: issue.id, type: 'issues'}}
          }
        })
      end.to change{ Workflow.count }.by 1

      assert_logging(Workflow.last, :create_entity, 1)
      workflow = Workflow.find(api_response.data.id)

      api_get("/workflows/#{workflow.id}")

      data = api_response.data
      expect(data.relationships.issue.data.id.to_i).to eq issue.id
      expect(data.attributes.scope).to eq "robot"
      expect(data.attributes.workflow_type).to eq "onboarding"

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
        attributes: {scope: 'admin', workflow_type: 'risk_check'}
      }

      api_response.data.attributes.scope.should == 'admin'
      api_response.data.attributes.workflow_type.should == 'risk_check'

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

        task_one = workflow.tasks.first
        task_two = workflow.tasks.second

        api_request :post, "/tasks/#{task_one.id}/start", {}, 200
        api_update "/tasks/#{task_one.id}", {
          type: 'tasks',
          attributes: {output: 'All ok'}
        }
        api_request :post, "/tasks/#{task_one.id}/finish", {}, 200

        api_request :post, "/workflows/#{workflow.id}/finish", {}, 422

        api_request :post, "/tasks/#{task_two.id}/start", {}, 200
        api_update "/tasks/#{task_two.id}", {
          type: 'tasks',
          attributes: {output: 'All ok'}
        }
        api_request :post, "/tasks/#{task_two.id}/finish", {}, 200

        api_request :post, "/workflows/#{workflow.id}/finish", {}, 200
        
        expect(workflow.reload).to have_state(:performed)
      end

      it 'if all tasks failed workflow does not became failed automatically' do
        workflow = create(:basic_workflow)

        2.times do
          create(:basic_task, workflow: workflow, max_retries: 0)
        end

        api_request :post, "/workflows/#{workflow.id}/start", {}, 200 

        task_one = workflow.reload.tasks.first
        task_two = workflow.tasks.second

        api_request :post, "/tasks/#{task_one.id}/start", {}, 200
        api_request :post, "/tasks/#{task_one.id}/fail", {}, 200
        api_request :post, "/tasks/#{task_two.id}/start", {}, 200
        api_request :post, "/tasks/#{task_two.id}/fail", {}, 200

        api_get "/workflows/#{workflow.id}", {}, 200

        api_response.data.attributes.state.should == 'started'

        api_request :post, "/workflows/#{workflow.id}/fail", {}, 200
      end
    end
  end

  describe "When filter by admin tags" do
    let(:admin_user) { create(:admin_user) }

    before :each do
      admin_user.tags.clear
      admin_user.save!
    end

    it "allow workflow creation only with person valid admin tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:alt_full_person_tagging).person

      admin_user.tags << person1.tags.first
      admin_user.save!

      issue1 = create(:basic_issue, person: person1)
      issue2 = create(:basic_issue, person: person2)

      expect do
        api_create('/workflows',
          type: 'workflows',
          attributes: {
            workflow_type: 'onboarding',
            scope: 'robot'
          },
          relationships: {
            issue: { data: { id: issue1.id, type: 'issues' } }
          })
      end.to change { Workflow.count }.by 1

      workflow = Workflow.last
      expect(api_response.data.id).to eq(workflow.id.to_s)

      expect do
        api_create('/workflows', {
          type: 'workflows',
          attributes: {
            workflow_type: 'onboarding',
            scope: 'robot'
          },
          relationships: {
            issue: { data: { id: issue2.id, type: 'issues' } }
          }}, 404)
      end.to change { Workflow.count }.by(0)

      expect(workflow).to eq(Workflow.last)

      admin_user.tags << person2.tags.first
      admin_user.save!

      expect do
        api_create('/workflows',
          type: 'workflows',
          attributes: {
            workflow_type: 'onboarding',
            scope: 'robot'
          },
          relationships: {
            issue: { data: { id: issue1.id, type: 'issues' } }
          })
      end.to change { Workflow.count }.by 1

      workflow = Workflow.last
      expect(api_response.data.id).to eq(workflow.id.to_s)

      expect do
        api_create('/workflows',
          type: 'workflows',
          attributes: {
            workflow_type: 'onboarding',
            scope: 'robot'
          },
          relationships: {
            issue: { data: { id: issue2.id, type: 'issues' } }
          })
      end.to change { Workflow.count }.by 1

      workflow = Workflow.last
      expect(api_response.data.id).to eq(workflow.id.to_s)
    end

    it "allow workflow creation with person tags if admin has no tags" do
      person = create(:full_person_tagging).person
      issue = create(:basic_issue, person: person)

      expect do
        api_create('/workflows',
          type: 'workflows',
          attributes: {
            workflow_type: 'onboarding',
            scope: 'robot'
          },
          relationships: {
            issue: { data: { id: issue.id, type: 'issues' } }
          })
      end.to change { Workflow.count }.by 1
    end

    it "allow workflow creation without person tags if admin has no tags" do
      person = create(:empty_person)
      issue = create(:basic_issue, person: person)
      
      expect do
        api_create('/workflows',
          type: 'workflows',
          attributes: {
            workflow_type: 'onboarding',
            scope: 'robot'
          },
          relationships: {
            issue: { data: { id: issue.id, type: 'issues' } }
          })
      end.to change { Workflow.count }.by 1
    end

    it "allow workflow creation without person tags if admin has tags" do
      person = create(:full_person_tagging).person
      issue = create(:basic_issue, person: person)

      admin_user.tags << person.tags.first
      admin_user.save!

      expect do
        api_create('/workflows',
          type: 'workflows',
          attributes: {
            workflow_type: 'onboarding',
            scope: 'robot'
          },
          relationships: {
            issue: { data: { id: issue.id, type: 'issues' } }
          })
      end.to change { Workflow.count }.by 1
    end

    it "Update a workflow with person tags if admin has tags" do
      workflow1, workflow2, workflow3, workflow4 = setup_for_admin_tags_spec
      person1 = workflow1.issue.person
      person3 = workflow3.issue.person

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_update "/workflows/#{workflow1.id}",
        type: 'workflows',
        attributes: { scope: 'admin', workflow_type: 'risk_check' }

      api_update "/workflows/#{workflow2.id}",
        type: 'workflows',
        attributes: { scope: 'admin', workflow_type: 'risk_check' }

      api_update "/workflows/#{workflow3.id}", {
      type: 'workflows',
      attributes: { scope: 'admin', workflow_type: 'risk_check' }
      }, 404

      api_update "/workflows/#{workflow4.id}",
      type: 'workflows',
      attributes: { scope: 'admin', workflow_type: 'risk_check' }

      admin_user.tags << person3.tags.first
      admin_user.save!

      api_update "/workflows/#{workflow3.id}",
        type: 'workflows',
        attributes: { scope: 'admin', workflow_type: 'risk_check' }
    end

    it "Destroy a task with person tags if admin has tags" do
      workflow1, workflow2, workflow3, workflow4 = setup_for_admin_tags_spec
      person1 = workflow1.issue.person
      person3 = workflow3.issue.person

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_destroy "/workflows/#{workflow1.id}"
      response.body.should be_blank
      api_get "/workflows/#{workflow1.id}", {}, 404

      api_destroy "/workflows/#{workflow2.id}"
      response.body.should be_blank
      api_get "/workflows/#{workflow2.id}", {}, 404

      api_destroy "/workflows/#{workflow3.id}", 404

      api_destroy "/workflows/#{workflow4.id}"
      response.body.should be_blank
      api_get "/workflows/#{workflow4.id}", {}, 404

      admin_user.tags << person3.tags.first
      admin_user.save!

      api_destroy "/workflows/#{workflow3.id}"
      response.body.should be_blank
      api_get "/workflows/#{workflow3.id}", {}, 404
    end

    it "show workflow with admin user active tags" do
      workflow1, workflow2, workflow3, workflow4 = setup_for_admin_tags_spec
      person1 = workflow1.issue.person
      person3 = workflow3.issue.person

      api_get("/workflows/#{workflow1.id}")
      api_get("/workflows/#{workflow2.id}")
      api_get("/workflows/#{workflow3.id}")
      api_get("/workflows/#{workflow4.id}")

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/workflows/#{workflow1.id}")
      api_get("/workflows/#{workflow2.id}")
      api_get("/workflows/#{workflow3.id}", {}, 404)
      api_get("/workflows/#{workflow4.id}")

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      api_get("/workflows/#{workflow1.id}", {}, 404)
      api_get("/workflows/#{workflow2.id}")
      api_get("/workflows/#{workflow3.id}")
      api_get("/workflows/#{workflow4.id}")

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/workflows/#{workflow1.id}")
      api_get("/workflows/#{workflow2.id}")
      api_get("/workflows/#{workflow3.id}")
      api_get("/workflows/#{workflow4.id}")
    end

    it "index workflow with admin user active tags" do
      workflow1, workflow2, workflow3, workflow4 = setup_for_admin_tags_spec
      person1 = workflow1.issue.person
      person3 = workflow3.issue.person

      api_get("/workflows/")
      expect(api_response.meta.total_items).to eq(4)
      expect(api_response.data[0].id).to eq(workflow4.id.to_s)
      expect(api_response.data[1].id).to eq(workflow3.id.to_s)
      expect(api_response.data[2].id).to eq(workflow2.id.to_s)
      expect(api_response.data[3].id).to eq(workflow1.id.to_s)

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/workflows/")
      expect(api_response.meta.total_items).to eq(3)
      expect(api_response.data[0].id).to eq(workflow4.id.to_s)
      expect(api_response.data[1].id).to eq(workflow2.id.to_s)
      expect(api_response.data[2].id).to eq(workflow1.id.to_s)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      api_get("/workflows/")
      expect(api_response.meta.total_items).to eq(3)
      expect(api_response.data[0].id).to eq(workflow4.id.to_s)
      expect(api_response.data[1].id).to eq(workflow3.id.to_s)
      expect(api_response.data[2].id).to eq(workflow2.id.to_s)

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/workflows/")
      expect(api_response.meta.total_items).to eq(4)
      expect(api_response.data[0].id).to eq(workflow4.id.to_s)
      expect(api_response.data[1].id).to eq(workflow3.id.to_s)
      expect(api_response.data[2].id).to eq(workflow2.id.to_s)
      expect(api_response.data[3].id).to eq(workflow1.id.to_s)
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
