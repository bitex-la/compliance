require 'rails_helper'
require 'helpers/api/issues_helper'
require 'json'

describe Issue do
  let(:person) { create(:empty_person) }
  
  def assert_issue_integrity(seed_list = [])
    Issue.count.should == 1
    Person.count.should == 1
    Issue.first.person.should == person
    seed_list.each do |seed_type|
      seed_type.constantize.count.should == 1
      seed_type.constantize.last.issue.should == Issue.first
      seed_type.constantize.last.attachments.count.should == 1
    end
  end

  describe 'Creating an Issue' do
    it 'responds with an Unprocessable Entity HTTP code (422) when body is empty' do
      post "/api/people/#{person.id}/issues",  params: {}
      assert_response 422
    end

    %i(png gif pdf jpg zip).each do |ext|
      describe "receives a #{ext} attachment and" do
        it 'creates a new issue with a domicile seed' do
          issue  = Api::IssuesHelper.issue_with_domicile_seed(ext)
          post "/api/people/#{person.id}/issues", params: issue
          assert_issue_integrity(["DomicileSeed"]) 
          assert_response 201
        end

        it 'creates a new issue with an identification seed' do
          issue  = Api::IssuesHelper.issue_with_identification_seed(ext)
          post "/api/people/#{person.id}/issues", params: issue
          assert_issue_integrity(["IdentificationSeed"]) 
          assert_response 201
        end

        it 'creates a new issue with a natural docket seed' do
          issue  = Api::IssuesHelper.issue_with_natural_docket_seed(ext)
          post "/api/people/#{person.id}/issues", params: issue
          assert_issue_integrity(["NaturalDocketSeed"]) 
          assert_response 201
        end

        it 'creates a new issue with a legal entity docket seed' do
          issue  = Api::IssuesHelper.issue_with_legal_entity_docket_seed(ext)
          post "/api/people/#{person.id}/issues", params: issue
          assert_issue_integrity(["LegalEntityDocketSeed"]) 
          assert_response 201
        end

        it 'creates a new issue with a allowance seed' do
          issue  = Api::IssuesHelper.issue_with_allowance_seed(ext)
          post "/api/people/#{person.id}/issues", params: issue
          assert_issue_integrity(["AllowanceSeed"]) 
          assert_response 201
        end
      end
    end
  end

  describe 'Updating an issue' do
    it 'responds with 404 when issue does not exist' do
      person = create :full_natural_person
      patch "/api/people/#{person.id}/issues/#{Issue.last.id + 100}"
      assert_response 404
    end

    it 'responds with 404 when issue belongs to someone else' do
      person = create :full_natural_person
      other = create :full_natural_person
      patch "/api/people/#{person.id}/issues/#{other.issues.last.id}"
      assert_response 404
    end

    it 'responds to an observation changing the domicile' do
      post "/api/people/#{person.id}/issues",
        params: Api::IssuesHelper.issue_with_domicile_seed(:png)
      create(:observation, issue: Issue.last)
 
      assert_issue_integrity(["DomicileSeed"])

      issue_document = json_response

      issue_document[:included][1][:attributes] = {
        country: "Argentina",
        state: "Baires", 
        street_address: "Mitre",
        street_number: "6782",
        postal_code: "1341",
        floor: "1",
        apartment: "N/A"	  
      } 
      issue_document[:included][2] = {
        type: 'observations',
        id: Observation.last.id,
        attributes: {
          reply: "Mire, mejor me cambio la dirección"
        }
      }

      patch "/api/people/#{person.id}/issues/#{person.issues.last.id}",
        params: JSON.dump(issue_document),
        headers: {"CONTENT_TYPE" => 'application/json' }
      assert_response 200

      DomicileSeed.first.tap do |seed|
        seed.reload
        seed.country.should == "Argentina"
        seed.state.should == "Baires"
        seed.city == "CABA"
        seed.street_address == 'Mitre'
        seed.postal_code == "1341"
        seed.floor == "1"
        seed.apartment == "N/A"
      end

      Issue.last.should be_answered
    end
  end

  describe 'Getting an issue' do
    it 'responds with a not found error 404 when the issue does not exist' do
      get "/api/people/#{person.id}/issues/1"
      assert_response 404
    end

    it 'shows all the person info when the issue exist' do  
      issue  = Api::IssuesHelper.issue_with_domicile_seed(:png)
      post "/api/people/#{person.id}/issues", params: issue
      response_for_post = response.body

      assert_issue_integrity(["DomicileSeed"])
  
      get  "/api/people/#{person.id}/issues/#{Issue.first.id}"
      assert_response 200
      response.body.should == response_for_post
    end
  end
end
