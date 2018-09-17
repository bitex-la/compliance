require 'rails_helper'
require 'helpers/api/api_helper'
require 'json'

describe Observation do 
  let(:person) { create(:empty_person) }

  it_behaves_like 'jsonapi show and index',
    :observations,
    :robot_observation_with_issue,
    :admin_world_check_observation_with_issue,
    {scope_eq: 'admin'},
    'scope,observation_reason',
    'observation_reason'

  describe 'Creating a new observation' do
    it 'responds with (422) when body is empty' do
      api_create "/observations", {}, 422
    end

    it 'creates a new observation for an issue' do
      issue = create(:basic_issue)
      reason = create(:world_check_reason)
      attributes = attributes_for(:robot_observation)

      api_create "/observations", {
        type: 'observations',
        attributes: attributes,
        relationships: {
          issue: {data: {id: issue.id, type: 'issues'}},
          observation_reason: {
            data: {id: reason.id, type: 'observation_reasons'}
          }
        }
      }

      api_response.data.attributes.to_h.should >= attributes
      api_response.data.relationships.issue.data.id.should == issue.id.to_s
    end
  end

  it 'replies to an observation' do 
    issue = create(:basic_issue)
    observation = create(:robot_observation, issue: issue)

    api_update "/observations/#{observation.id}", {
      type: 'observations',
      id: observation.id,
      attributes: {reply: "Some reply here"}
    }
    api_response.data.attributes.state.should == 'answered'

    api_get "/issues/#{issue.id}"
    api_response.data.attributes.state.should == 'answered'
  end
end

