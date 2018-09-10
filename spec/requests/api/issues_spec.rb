require 'rails_helper'
require 'helpers/api/issues_helper'
require 'helpers/api/api_helper'
require 'json'

describe Issue do
  let(:person) { create(:empty_person) }
  let(:admin_user) { create(:admin_user) }

  def assert_issue_integrity(seed_list = [])
    Issue.count.should == 1
    Person.count.should == 1
    Issue.first.person.should == person
    seed_list.each do |seed_type|
      seed_type.constantize.count.should == 1
      seed_type.constantize.last.issue.should == Issue.first
      if !SELF_HARVESTABLE_SEEDS.include? seed_type
        seed_type.constantize.last.attachments.count.should == 1
      end
    end
  end

  def assert_replacement_issue_integrity(seed_list = [])
    Issue.count == 2
    seed_list.each do |seed_type|
      seed_type.constantize.count.should == 2
      seed_type.constantize.last.reload.issue.should == Issue.last
      seed_type.constantize.last.attachments.count.should == 1
    end
  end

  describe 'Creating a new user Issue' do
    it 'responds with an Unprocessable Entity HTTP code (422) when body is empty' do
      post "/api/issues",
        params: {},
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }
      assert_response 422
    end

    it 'creates a new issue with an observation' do
      reason = create(:human_world_check_reason)
      issue  = Api::IssuesHelper.issue_with_an_observation(person.id, reason, 'test')
      post "/api/issues",
        params: issue,
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      assert_response 201
      assert_logging(Issue.last, :create_entity, 1)
    end

    %i(png gif pdf jpg zip PNG GIF PDF JPG ZIP).each do |ext|
      it "creates a new issue with a domicile seed and #{ext} attachment" do
        issue  = Api::IssuesHelper.issue_with_domicile_seed(person, ext, true)
        post "/api/issues",
          params: issue,
          headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

        assert_issue_integrity(["DomicileSeed"])
        assert_response 201
        assert_logging(Issue.last, :create_entity, 1)
      end
    end

    it 'creates a new issue with an identification seed' do
      issue  = Api::IssuesHelper.issue_with_identification_seed(person, :gif)
      post "/api/issues",
        params: issue,
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      assert_issue_integrity(["IdentificationSeed"])
      assert_response 201
      assert_logging(Issue.last, :create_entity, 1)
    end

    it 'creates a new issue with a risk score seed' do
      issue  = Api::IssuesHelper.issue_with_risk_score_seed(person, :gif, true)
      post "/api/issues",
        params: issue,
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      assert_issue_integrity(["RiskScoreSeed"])
      assert_response 201
      assert_logging(Issue.last, :create_entity, 1)
    end

    it 'creates a new issue with a phone seed' do
      issue  = Api::IssuesHelper.issue_with_phone_seed(person, :gif)
      post "/api/issues",
        params: issue,
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      assert_issue_integrity(["PhoneSeed"])
      assert_response 201
      assert_logging(Issue.last, :create_entity, 1)
    end

    it 'creates a new issue with an email seed' do
      issue  = Api::IssuesHelper.issue_with_email_seed(person, :gif, true)
      post "/api/issues",
        params: issue,
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      assert_issue_integrity(["EmailSeed"])
      assert_response 201

      assert_logging(Issue.last, :create_entity, 1)
    end

    it 'creates a new issue with an affinity seed' do
      related_person = create(:empty_person)
      issue  = Api::IssuesHelper.issue_with_affinity_seed(person, related_person, :gif)
      post "/api/issues",
        params: issue,
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      Issue.count.should == 1
      Person.count.should == 2
      Issue.first.person.should == person
      AffinitySeed.count.should == 1
      AffinitySeed.last.issue.should == Issue.first
      AffinitySeed.last.attachments.count.should == 1
      assert_response 201

      assert_logging(Issue.last, :create_entity, 1)
    end

    it 'creates a new issue with an argentina invoicing seed' do
      issue  = Api::IssuesHelper.issue_with_argentina_invoicing_seed(person, :gif, true)
      post "/api/issues",
        params: issue,
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      assert_issue_integrity(["ArgentinaInvoicingDetailSeed"])
      assert_response 201

      assert_logging(Issue.last, :create_entity, 1)
    end

    it 'creates a new issue with a chile invoicing seed' do
      issue  = Api::IssuesHelper.issue_with_chile_invoicing_seed(person, :gif)
      post "/api/issues",
        params: issue,
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      assert_issue_integrity(["ChileInvoicingDetailSeed"])
      assert_response 201

      assert_logging(Issue.last, :create_entity, 1)
    end

    it 'creates a new issue with a natural docket seed' do
      issue  = Api::IssuesHelper.issue_with_natural_docket_seed(person, :gif, true)
      post "/api/issues",
        params: issue,
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      assert_issue_integrity(["NaturalDocketSeed"])
      assert_response 201

      assert_logging(Issue.last, :create_entity, 1)
    end

    it 'creates a new issue with a legal entity docket seed' do
      issue  = Api::IssuesHelper.issue_with_legal_entity_docket_seed(person, :gif)
      post "/api/issues",
        params: issue,
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      assert_issue_integrity(["LegalEntityDocketSeed"])
      assert_response 201

      assert_logging(Issue.last, :create_entity, 1)
    end

    it 'creates a new issue with a allowance seed' do
      issue  = Api::IssuesHelper.issue_with_allowance_seed(person, :gif, true)
      post "/api/issues",
        params: issue,
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      assert_issue_integrity(["AllowanceSeed"])
      assert_response 201

      assert_logging(Issue.last, :create_entity, 1)
    end
  end

  describe 'When updating a person via issues' do
    let(:full_natural_person){ create :full_natural_person }

    %i(png gif pdf jpg zip).each do |ext|
      it "adds issue to replace domicile, and add #{ext} attachment" do
        issue  = Api::IssuesHelper.issue_with_domicile_seed(full_natural_person, ext)
        issue[:included][0][:relationships].merge!({
          replaces: { data: { type: 'domiciles', id: Domicile.last.id.to_s } }
        })

        post "/api/issues", params: issue,
          headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

        assert_replacement_issue_integrity(["DomicileSeed"])
        DomicileSeed.last.replaces.should == Domicile.last
        DomicileSeed.first.replaces.should be_nil
        assert_response 201

        assert_logging(Issue.last, :create_entity, 1)
      end
    end

    it 'creates a new issue with an identification seed who wants to replace the current identification' do
      issue  = Api::IssuesHelper.issue_with_identification_seed(person, :gif, true)
      issue[:included][0][:relationships].merge!({
        replaces: { data: { type: 'identifications', id: Identification.last.id.to_s } }
      })

      post "/api/issues", params: issue,
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      assert_replacement_issue_integrity(["IdentificationSeed"])
      IdentificationSeed.last.replaces.should == Identification.last
      IdentificationSeed.first.replaces.should be_nil
      assert_response 201

      assert_logging(Issue.last, :create_entity, 1)
    end

    it 'creates a new issue with a risk score seed who wants to replace the current risk score' do
      issue  = Api::IssuesHelper.issue_with_risk_score_seed(person, :gif)
      issue[:included][0][:relationships].merge!({
        replaces: { data: { type: 'risk_scores', id: RiskScore.last.id.to_s } }
      })

      post "/api/issues", params: issue,
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      assert_replacement_issue_integrity(["RiskScoreSeed"])
      RiskScoreSeed.last.replaces.should == RiskScore.last
      RiskScoreSeed.first.replaces.should be_nil
      assert_response 201

      assert_logging(Issue.last, :create_entity, 1)
    end

    it 'creates a new issue with an allowance seed who wants to replace the current allowance' do
      issue  = Api::IssuesHelper.issue_with_allowance_seed(person, :gif, true)
      issue[:included][0][:relationships].merge!({
        replaces: { data: { type: 'allowances', id: Allowance.last.id.to_s } }
      })

      post "/api/issues", params: issue,
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      Issue.count.should == 2
      AllowanceSeed.count.should == 3
      AllowanceSeed.last.issue.should == Issue.last
      AllowanceSeed.last.attachments.count.should == 1
      AllowanceSeed.last.replaces.should == Allowance.last
      AllowanceSeed.first.replaces.should be_nil
      assert_response 201

      assert_logging(Issue.last, :create_entity, 1)
    end

    it 'creates a new issue with a phone seed who wants to replace the current phone' do
      issue  = Api::IssuesHelper.issue_with_phone_seed(person, :gif)
      issue[:included][0][:relationships].merge!({
        replaces: { data: { type: 'phones', id: Phone.last.id.to_s } }
      })

      post "/api/issues", params: issue,
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      Issue.count.should == 2
      PhoneSeed.count.should == 2
      PhoneSeed.last.issue.should == Issue.last
      PhoneSeed.last.attachments.count.should == 1
      PhoneSeed.last.replaces.should == Phone.last
      PhoneSeed.first.replaces.should be_nil
      assert_response 201

      assert_logging(Issue.last, :create_entity, 1)
    end

    it 'creates a new issue with an email seed who wants to replace the current email' do
      issue  = Api::IssuesHelper.issue_with_email_seed(person, full_natural_person, :gif)
      issue[:included][0][:relationships].merge!({
        replaces: { data: { type: 'emails', id: Email.last.id.to_s } }
      })

      post "/api/issues", params: issue,
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }
      assert_response 201

      Issue.count.should == 2
      EmailSeed.count.should == 2
      EmailSeed.last.issue.should == Issue.last
      EmailSeed.last.attachments.count.should == 1
      EmailSeed.last.replaces.should == Email.last
      EmailSeed.first.replaces.should be_nil

      assert_logging(Issue.last, :create_entity, 1)
    end

    it 'creates a new issue with an affinity seed who wants to replace the current affinity' do
      new_partner = create(:empty_person)
      issue  = Api::IssuesHelper.issue_with_affinity_seed(person, new_partner, :gif)
      issue[:included][0][:relationships].merge!({
        replaces: { data: { type: 'affinities', id: full_natural_person.affinities.reload.first.id.to_s } }
      })

      post "/api/issues", params: issue,
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      Issue.count.should == 2
      AffinitySeed.count.should == 2
      AffinitySeed.last.issue.should == Issue.last
      AffinitySeed.last.replaces.should == Person.second.affinities.first
      AffinitySeed.first.replaces.should be_nil
      assert_response 201

      assert_logging(Issue.last, :create_entity, 1)
    end
  end

  describe 'Updating an issue' do
    it 'responds with 404 when issue does not exist' do
      person = create :full_natural_person
      patch "/api/issues/#{Issue.last.id + 100}",
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }
      assert_response 404
    end

    it 'responds with 404 when issue belongs to someone else' do
      person = create :full_natural_person
      other = create :full_natural_person
      patch "/api/issues/#{other.issues.last.id}",
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }
      assert_response 404
    end

    it 'responds to an observation changing the domicile' do
      post "/api/issues",
        params: Api::IssuesHelper.issue_with_domicile_seed(person, :png),
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      create(:observation, issue: Issue.last)

      assert_issue_integrity(["DomicileSeed"])

      issue_document = json_response

      issue_document[:included][0][:attributes] = {
        country: "AR",
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
        },
        relationships: {
          issue: {data: {id: Issue.last.id, type: "issues"}},
          observation_reason: {
            data:
            {
              id: Observation.last.observation_reason.id.to_s,
              type: "observation_reasons"
            }
          }
        }
      }

      patch "/api/issues/#{person.issues.reload.last.id}",
        params: JSON.dump(issue_document),
        headers: {"CONTENT_TYPE" => 'application/json',
                 'Authorization' => "Token token=#{admin_user.api_token}"}

      assert_response 200

      DomicileSeed.first.tap do |seed|
        seed.reload
        seed.country.should == "AR"
        seed.state.should == "Baires"
        seed.city == "CABA"
        seed.street_address == 'Mitre'
        seed.postal_code == "1341"
        seed.floor == "1"
        seed.apartment == "N/A"
      end

      Issue.last.should be_answered
      assert_logging(Issue.last, :create_entity, 1)
    end

    it 'responds to an observation changing the phone' do
      post "/api/issues",
        params: Api::IssuesHelper.issue_for(person),
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }
      assert_response 200

      post "/api/phone_seeds",
        params: Api::IssuesHelper.phone_seed_for(issue),
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }
      phone_seed_document = json_response
      assert_response 200

      post "/api/attachments", 
        params: Api::IssuesHelper.attachment_for(PhoneSeed.last),
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }
      assert_response 200

      issue = Issue.last

      get "/api/issue/#{issue.id}"
      assert_issue_integrity(["PhoneSeed"])

      observation = create(:observation, issue: issue)

      # Now the user changes the phone seed and replies to the observation
      post "/api/phone_seeds",
        params: Api::IssuesHelper.phone_seed_for(issue),
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }
      assert_response 200

      phone_seed_document[:attributes] = {
        number: "+571165342178",
        kind: "2",
        country: "CO",
        has_whatsapp: true,
        has_telegram: false,
        note: "Please use whatsapp"
      }

      observation_document = {
        data: {
          type: 'observations',
          id: observation.id,
          attributes: { reply: "Mire, mi nuevo telefono" },
        }
      }

      patch "/api/issues/#{person.issues.reload.last.id}",
        params: JSON.dump(issue_document),
        headers: {"CONTENT_TYPE" => 'application/json',
                  "Authorization" => "Token token=#{admin_user.api_token}"}
      assert_response 200

      PhoneSeed.first.tap do |seed|
        seed.reload
        seed.number.should == "+54911282256470"
        seed.phone_kind_code.should == :main
        seed.country.should == "AR"
        seed.has_whatsapp.should == true
        seed.has_telegram.should == false
        seed.note.should == "only on office hours"
      end

      Issue.last.should be_answered
      assert_logging(Issue.last, :create_entity, 1)
    end

    it 'can answer an observation and add a new one in one step' do
      person = create :new_natural_person
      issue = person.issues.reload.last
      create :robot_observation, issue: issue

      get "/api/issues/#{issue.id}",
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      issue_request = json_response

      observation = Api::IssuesHelper.observation_for(
        issue.id, create(:human_world_check_reason), "Run manually")

      issue_request[:included]
        .find{|i| i[:type] == 'observations'}[:attributes] = { reply: "hits" }

      issue_request[:data][:relationships][:observations][:data] <<
        observation.slice(:id, :type)

      issue_request[:included] << observation

      patch "/api/issues/#{issue.id}",
        params: issue_request.to_json,
        headers: {"CONTENT_TYPE" => 'application/json',
                  "Authorization" => "Token token=#{admin_user.api_token}"}
           
      api_response.data.attributes.state.should == "observed"
      observations = api_response.included.select{|i| i.type == 'observations' }
      observations.count.should == 2
      observations.map{|o| o.attributes.state }.should == %w(answered new)
    
      assert_logging(Issue.last, :create_entity, 1)
    end
  end

  describe 'Getting an issue' do
    it 'responds with a not found error 404 when the issue does not exist' do
      get "/api/issues/1",
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      assert_response 404
    end

    it 'shows all the person info when the issue exist' do
      issue  = Api::IssuesHelper.issue_with_domicile_seed(person, :png)
      post "/api/issues",
        params: issue,
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      response_for_post = response.body

      assert_issue_integrity(["DomicileSeed"])

      get  "/api/issues/#{Issue.first.id}",
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      assert_response 200
      response.body.should == response_for_post
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

        post "/api/issues/#{issue.id}/#{action}", 
          headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

        assert_response 200
      end

      it "It cannot #{action} approved issue" do
        issue = create(:basic_issue, state: :approved, person: person)

        post "/api/issues/#{issue.id}/#{action}", 
          headers: { 'Authorization': "Token token=#{admin_user.api_token}" }
        assert_response 422
      end
    end
  end
end
