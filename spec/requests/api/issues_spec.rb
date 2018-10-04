require 'rails_helper'

describe Issue do
  let(:person) { create(:empty_person) }

  it_behaves_like 'jsonapi show and index',
    :issues,
    :basic_issue,
    :full_approved_natural_person_issue,
    {state_eq: 'approved'},
    'domicile_seeds,person',
    'identification_seeds,domicile_seeds'

  describe 'When fetching issues' do
    it 'includes relationships for all issues' do
      one = create(:full_natural_person).reload.issues.first
      two = create(:basic_issue)

      api_get "/issues"

      api_response.data.size.should == 2

      by_type = api_response.included
        .group_by{|i| i.type }
        .map{|a,b| [a, b.count ] }.to_h
        .should == {
          "people"=>2,
          "affinity_seeds"=>1,
          "attachments"=>121,
          "allowance_seeds"=>2,
          "argentina_invoicing_detail_seeds"=>1,
          "domicile_seeds"=>1,
          "email_seeds"=>1,
          "identification_seeds"=>1,
          "natural_docket_seeds"=>1,
          "note_seeds"=>1,
          "affinities"=>1,
          "allowances"=>2,
          "argentina_invoicing_details"=>1,
          "domiciles"=>1,
          "emails"=>1,
          "fund_deposits"=>1,
          "identifications"=>1,
          "natural_dockets"=>1,
          "notes"=>1,
          "phones"=>1,
          "risk_scores"=>1,
          "phone_seeds"=>1,
          "risk_score_seeds"=>1
        }
    end
  end

  describe 'Creating a new user Issue' do
    it 'requires a valid api key' do
      forbidden_api_request(:post, "/issues", {
        type: 'issues',
        relationships: { person: {data: {id: person.id, type: 'people'}}}
      })
    end

    it 'responds with an Unprocessable Entity when body is empty' do
      api_request :post, "/issues", {}, 422
    end

    it 'creates a new issue, and adds observation' do
      reason = create(:human_world_check_reason)

      expect do
        api_create('/issues', {
          type: 'issues',
          relationships: { person: {data: {id: person.id, type: 'people'}}}
        })
      end.to change{ Issue.count }.by(1)

      issue_id = api_response.data.id

      assert_logging(Issue.last, :create_entity, 1)

      expect do
        api_create('/observations', {
          type: 'observations',
          attributes: {note: 'Observation Note', scope: 'admin'},
          relationships: {
            issue: {data: {type: 'issues', id: issue_id }},
            observation_reason: {
              data: {type: 'observation_reasons', id: reason.id}
            }
          }
        })
      end.to change{ Observation.count }.by(1)

      observation_id = api_response.data.id

      assert_logging(Observation.last, :create_entity, 1)

      api_get("/issues/#{issue_id}")

      api_response.data.attributes.state.should == 'observed'
      api_response.data.relationships.observations
        .data.first.id.should == observation_id
      api_response.included.select{|o| o.type == 'observations'}
        .map(&:id).should == [observation_id]
    end
  end

  describe "when changing state" do
    { complete: :draft,
      observe: :new,
      answer: :observed,
      dismiss: :new,
      reject: :new,
      approve: :new,
      abandon: :new
    }.each do |action, initial_state|
      it "It can #{action} issue" do
        issue = create(:basic_issue, state: initial_state, person: person)
        api_request :post, "/issues/#{issue.id}/#{action}", {}, 200
      end

      it "It cannot #{action} approved issue" do
        issue = create(:basic_issue, state: :approved, person: person)
        api_request :post, "/issues/#{issue.id}/#{action}", {}, 422
      end
    end
  end

  describe 'when using filters' do
    it 'filters by name' do
      person = create(:empty_person)
      one, two, three, four, five, six = 6.times.map do 
        create(:full_natural_person_issue, person: person)
      end
      [one, two, three].each{|i| i.approve! }

      api_get "/issues/?filter[active]=true"
      api_response.data.map{|i| i.id.to_i}.to_set.should ==
				[four.id, five.id, six.id].to_set

      api_get "/issues/?filter[active]=false"
      api_response.data.map{|i| i.id.to_i}.to_set.should ==
				[one.id, two.id, three.id].to_set

      api_get "/issues/?filter[state_eq]=approved"
      api_response.data.map{|i| i.id.to_i}.to_set.should ==
				[one.id, two.id, three.id].to_set
    end
  end
end
