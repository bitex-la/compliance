require 'rails_helper'
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

  it_behaves_like 'max people allowed request limit',
    :observations,
    :robot_observation_with_issue

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

    it 'creates a new observation for a seed' do
      issue = create(:full_natural_person_issue, person: create(:empty_person))
      reason = create(:world_check_reason)
      attributes = attributes_for(:robot_observation)

      seed = issue.reload.identification_seeds.first

      api_create "/observations", {
        type: 'observations',
        attributes: attributes,
        relationships: {
          issue: {data: {id: issue.id, type: 'issues'}},
          observation_reason: {
            data: {id: reason.id, type: 'observation_reasons'}
          },
          observable: {
            data: {
              id: seed.id , type: 'identification_seeds'
            }
          }
        }
      }

      api_response.data.attributes.to_h.should >= attributes
      api_response.data.relationships.issue.data.id.should == issue.id.to_s
      expect(api_response.data.relationships.observable.data.id).to eq(seed.id.to_s)
      expect(api_response.data.relationships.observable.data.type).to eq('identification_seeds')
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

  it 'only include observations from non future issues' do
    issue = create(:basic_issue)
    observation = create(:robot_observation, issue: issue)

    future_issue = create(:future_issue)
    create(:robot_observation, issue: future_issue)

    api_get "/observations"

    expect(api_response.meta.total_items).to eq(1)
    expect(api_response.data.first.id).to eq(observation.id.to_s)
  end
end
