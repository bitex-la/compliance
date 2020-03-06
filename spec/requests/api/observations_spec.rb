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

  describe "When filter by admin tags" do
    let(:admin_user) { create(:admin_user) }

    before :each do
      admin_user.tags.clear
      admin_user.save!
    end

    it "allow observation creation only with person valid admin tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:alt_full_person_tagging).person

      admin_user.tags << person1.tags.first
      admin_user.save!

      issue1 = create(:basic_issue, person: person1)
      issue2 = create(:basic_issue, person: person2)

      reason = create(:world_check_reason)
      attributes = attributes_for(:robot_observation)

      expect do
        api_create "/observations", {
          type: 'observations',
          attributes: attributes,
          relationships: {
            issue: { data: { id: issue1.id, type: 'issues' } },
            observation_reason: {
              data: { id: reason.id, type: 'observation_reasons'}
            }
          }
        }
      end.to change { Observation.count }.by(1)

      expect do
        api_create "/observations", {
          type: 'observations',
          attributes: attributes,
          relationships: {
            issue: { data: { id: issue2.id, type: 'issues' } },
            observation_reason: {
              data: { id: reason.id, type: 'observation_reasons'}
            }
          }
        }, 404
      end.to change { Observation.count }.by(0)
    end

    it "allow observation creation with person tags if admin has no tags" do
      person = create(:full_person_tagging).person
      issue = create(:basic_issue, person: person)
      reason = create(:world_check_reason)
      attributes = attributes_for(:robot_observation)

      expect do
        api_create "/observations", {
          type: 'observations',
          attributes: attributes,
          relationships: {
            issue: { data: { id: issue.id, type: 'issues' } },
            observation_reason: {
              data: { id: reason.id, type: 'observation_reasons'}
            }
          }
        }
      end.to change { Observation.count }.by(1)
    end

    it "allow observation creation without person tags if admin has no tags" do
      person = create(:empty_person)
      issue = create(:basic_issue, person: person)
      reason = create(:world_check_reason)
      attributes = attributes_for(:robot_observation)

      expect do
        api_create "/observations", {
          type: 'observations',
          attributes: attributes,
          relationships: {
            issue: { data: { id: issue.id, type: 'issues' } },
            observation_reason: {
              data: { id: reason.id, type: 'observation_reasons'}
            }
          }
        }
      end.to change { Observation.count }.by(1)
    end

    it "allow observation creation without person tags if admin has tags" do
      person = create(:full_person_tagging).person
      issue = create(:basic_issue, person: person)
      reason = create(:world_check_reason)
      attributes = attributes_for(:robot_observation)

      admin_user.tags << person.tags.first
      admin_user.save!

      expect do
        api_create "/observations", {
          type: 'observations',
          attributes: attributes,
          relationships: {
            issue: { data: { id: issue.id, type: 'issues' } },
            observation_reason: {
              data: { id: reason.id, type: 'observation_reasons'}
            }
          }
        }
      end.to change { Observation.count }.by(1)
    end

    it "show observations with admin user active tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:empty_person)
      person3 = create(:alt_full_person_tagging).person

      issue1 = create(:basic_issue, person: person1)
      issue2 = create(:basic_issue, person: person2)
      issue3 = create(:basic_issue, person: person3)

      obs1 = create(:robot_observation, issue: issue1)
      obs2 = create(:robot_observation, issue: issue2)
      obs3 = create(:robot_observation, issue: issue3)

      api_get("/observations/#{obs1.id}")
      api_get("/observations/#{obs2.id}")
      api_get("/observations/#{obs3.id}")

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/observations/#{obs1.id}")
      api_get("/observations/#{obs2.id}")
      api_get("/observations/#{obs3.id}", {}, 404)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      api_get("/observations/#{obs1.id}", {}, 404)
      api_get("/observations/#{obs2.id}")
      api_get("/observations/#{obs3.id}")
    end

    it "index observations with admin user active tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:empty_person)
      person3 = create(:alt_full_person_tagging).person

      issue1 = create(:basic_issue, person: person1)
      issue2 = create(:basic_issue, person: person2)
      issue3 = create(:basic_issue, person: person3)

      obs1 = create(:robot_observation, issue: issue1)
      obs2 = create(:robot_observation, issue: issue2)
      obs3 = create(:robot_observation, issue: issue3)

      api_get("/observations/")
      expect(api_response.meta.total_items).to eq(3)
      expect(api_response.data[0].id).to eq(obs3.id.to_s)
      expect(api_response.data[1].id).to eq(obs2.id.to_s)
      expect(api_response.data[2].id).to eq(obs1.id.to_s)

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/observations/")
      expect(api_response.meta.total_items).to eq(2)
      expect(api_response.data[0].id).to eq(obs2.id.to_s)
      expect(api_response.data[1].id).to eq(obs1.id.to_s)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      api_get("/observations/")
      expect(api_response.meta.total_items).to eq(2)
      expect(api_response.data[0].id).to eq(obs3.id.to_s)
      expect(api_response.data[1].id).to eq(obs2.id.to_s)
    end
  end
end
