require 'rails_helper'
require 'helpers/api/issues_helper'
require 'helpers/api/api_helper'
require 'json'

describe Issue do
  let(:person) { create(:empty_person) }
  let(:admin_user) { create(:admin_user) }

  describe 'When fetching issues' do
    it "can filter issues by state" do
      one = create(:basic_issue, updated_at: 2.month.ago)
      two = create(:full_natural_person).reload.issues.first
      three = create(:full_natural_person_issue,
        updated_at: 1.months.ago, person: two.person)
      four = create(:basic_issue)

      api_get "/issues", { 
        filter: { state_eq: 'draft' },
        page: { per_page: 2, page: 1 }
      }
      api_response.meta.total_pages.should == 2

      api_response.data.size.should == 2
      api_response.data.first.id.should == four.id.to_s
      api_response.data.last.id.should == three.id.to_s

      api_get "/issues", { 
        filter: { state_eq: 'draft' },
        page: { per_page: 2, page: 2 }
      }
      api_response.data.size.should == 1
      api_response.data.first.id.should == one.id.to_s
    end

    it "can filter issues by person_id" do
      one = create(:basic_issue)
      two = create(:full_natural_person).reload.issues.first
      three = create(:basic_issue)

      api_get "/issues", { filter: { person_id_eq: two.person_id } }

      api_response.meta.total_pages.should == 1
      api_response.data.size.should == 1
      api_response.data.first.id.should == two.id.to_s
    end

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
          "attachments"=>198,
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
      forbidden_api_request(:post, "/issues",
        Api::IssuesHelper.issue_for(nil, person.id))
    end

    it 'responds with an Unprocessable Entity when body is empty' do
      api_request :post, "/issues", {}, 422
    end

    it 'creates a new issue, and adds observation' do
      reason = create(:human_world_check_reason)

      expect do
        api_create('/issues', Api::IssuesHelper.issue_for(nil, person.id))
      end.to change{ Issue.count }.by(1)

      issue_id = api_response.data.id

      assert_logging(Issue.last, :create_entity, 1)

      expect do
        api_create('/observations', {
          type: 'observations',
          attributes: {
            note: 'Observation Note',
            scope: 'admin',
          },
          relationships: {
            issue: {
              data: { type: 'issues', id: issue_id }
            },
            observation_reason: {
              data: { type: 'observation_reasons', id: reason.id }
            }
          }
        })
      end.to change{ Observation.count }.by(1)

      observation_id = api_response.data.id

      assert_logging(Observation.last, :create_entity, 1)

      api_get("/issues/#{issue_id}")

      assert_resource("issues", issue_id, api_response.data)
      r = api_response.data.relationships
      assert_resource("people", person.id, r.person.data)
      assert_resource("observations", observation_id, r.observations.data.first)
    end
  end

  describe 'Getting an issue' do
    it 'responds with a not found error 404 when the issue does not exist' do
      api_get "/issues/12121221", {}, 404
    end

    it 'shows all the person info when the issue exist' do
      issue = create(:full_natural_person_issue, person: create(:empty_person))
      api_get "/issues/#{issue.id}"
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
end
