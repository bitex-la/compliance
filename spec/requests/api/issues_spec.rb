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
<<<<<<< HEAD
    it 'requires a valid api key' do
      forbidden_api_request(:post, "/issues", {
        type: 'issues',
        relationships: { person: {data: {id: person.id, type: 'people'}}}
      })
=======
    it 'responds with an Unprocessable Entity HTTP code (422) when body is empty' do
      post "/api/people/#{person.id}/issues",
        params: {},
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }
      assert_response 422
    end

    it 'creates a new issue with an observation' do
      reason = create(:human_world_check_reason)
      issue  = Api::IssuesHelper.issue_with_an_observation(person.id, reason, 'test')
      post "/api/people/#{person.id}/issues",
        params: issue,
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      assert_response 201
      assert_logging(Issue.last, :create_entity, 1)
    end

    %i(bmp png gif pdf jpg zip BMP PNG GIF PDF JPG ZIP).each do |ext|
      describe "receives a #{ext} attachment and" do
        it 'creates a new issue with a domicile seed' do
          issue  = Api::IssuesHelper.issue_with_domicile_seed(ext, true)
          post "/api/people/#{person.id}/issues",
            params: issue,
            headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

          assert_issue_integrity(["DomicileSeed"])
          assert_response 201
          assert_logging(Issue.last, :create_entity, 1)
        end

        it 'creates a new issue with an identification seed' do
          issue  = Api::IssuesHelper.issue_with_identification_seed(ext)
          post "/api/people/#{person.id}/issues",
            params: issue,
            headers: { 'Authorization': "Token token=#{admin_user.api_token}" }
 
          assert_issue_integrity(["IdentificationSeed"])
          assert_response 201
          assert_logging(Issue.last, :create_entity, 1)
        end

        it 'creates a new issue with a risk score seed' do
          issue  = Api::IssuesHelper.issue_with_risk_score_seed(ext, true)
          post "/api/people/#{person.id}/issues",
            params: issue,
            headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

          assert_issue_integrity(["RiskScoreSeed"])
          assert_response 201
          assert_logging(Issue.last, :create_entity, 1)
        end

        it 'creates a new issue with a phone seed' do
          issue  = Api::IssuesHelper.issue_with_phone_seed(ext)
          post "/api/people/#{person.id}/issues",
            params: issue,
            headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

          assert_issue_integrity(["PhoneSeed"])
          assert_response 201
          assert_logging(Issue.last, :create_entity, 1)
        end

        it 'creates a new issue with an email seed' do
          issue  = Api::IssuesHelper.issue_with_email_seed(ext, true)
          post "/api/people/#{person.id}/issues",
            params: issue,
            headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

          assert_issue_integrity(["EmailSeed"])
          assert_response 201

          assert_logging(Issue.last, :create_entity, 1)
        end

        it 'creates a new issue with an affinity seed' do
          related_person = create(:empty_person)
          issue  = Api::IssuesHelper.issue_with_affinity_seed(related_person, ext)
          post "/api/people/#{person.id}/issues",
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
          issue  = Api::IssuesHelper.issue_with_argentina_invoicing_seed(ext, true)
          post "/api/people/#{person.id}/issues",
            params: issue,
            headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

          assert_issue_integrity(["ArgentinaInvoicingDetailSeed"])
          assert_response 201

          assert_logging(Issue.last, :create_entity, 1)
        end

        it 'creates a new issue with a chile invoicing seed' do
          issue  = Api::IssuesHelper.issue_with_chile_invoicing_seed(ext)
          post "/api/people/#{person.id}/issues",
            params: issue,
            headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

          assert_issue_integrity(["ChileInvoicingDetailSeed"])
          assert_response 201

          assert_logging(Issue.last, :create_entity, 1)
        end

        it 'creates a new issue with a natural docket seed' do
          issue  = Api::IssuesHelper.issue_with_natural_docket_seed(ext, true)
          post "/api/people/#{person.id}/issues",
            params: issue,
            headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

          assert_issue_integrity(["NaturalDocketSeed"])
          assert_response 201

          assert_logging(Issue.last, :create_entity, 1)
        end

        it 'creates a new issue with a legal entity docket seed' do
          issue  = Api::IssuesHelper.issue_with_legal_entity_docket_seed(ext)
          post "/api/people/#{person.id}/issues",
            params: issue,
            headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

          assert_issue_integrity(["LegalEntityDocketSeed"])
          assert_response 201

          assert_logging(Issue.last, :create_entity, 1)
        end

        it 'creates a new issue with a allowance seed' do
          issue  = Api::IssuesHelper.issue_with_allowance_seed(ext, true)
          post "/api/people/#{person.id}/issues",
            params: issue,
            headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

          assert_issue_integrity(["AllowanceSeed"])
          assert_response 201

          assert_logging(Issue.last, :create_entity, 1)
        end
      end
    end
  end

  describe 'Updating people info' do
     %i(png gif pdf jpg zip).each do |ext|
      describe "receives a #{ext} attachment and" do
        it 'creates a new issue with a domicile seed who wants to replace the current domicile' do
          full_natural_person = create(:full_natural_person)
          issue  = Api::IssuesHelper.issue_with_domicile_seed(ext)
          issue[:included][0][:relationships].merge!({
            replaces: { data: { type: 'domiciles', id: Domicile.last.id.to_s } }
          })

          post "/api/people/#{full_natural_person.id}/issues",
            params: issue,
            headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

          assert_replacement_issue_integrity(["DomicileSeed"])
          DomicileSeed.last.replaces.should == Domicile.last
          DomicileSeed.first.replaces.should be_nil
          assert_response 201

          assert_logging(Issue.last, :create_entity, 1)
        end

        it 'creates a new issue with an identification seed who wants to replace the current identification' do
          full_natural_person = create(:full_natural_person)
          issue  = Api::IssuesHelper.issue_with_identification_seed(ext, true)
          issue[:included][0][:relationships].merge!({
            replaces: { data: { type: 'identifications', id: Identification.last.id.to_s } }
          })

          post "/api/people/#{full_natural_person.id}/issues",
            params: issue,
            headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

          assert_replacement_issue_integrity(["IdentificationSeed"])
          IdentificationSeed.last.replaces.should == Identification.last
          IdentificationSeed.first.replaces.should be_nil
          assert_response 201

          assert_logging(Issue.last, :create_entity, 1)
        end

        it 'creates a new issue with a risk score seed who wants to replace the current risk score' do
          full_natural_person = create(:full_natural_person)
          issue  = Api::IssuesHelper.issue_with_risk_score_seed(ext)
          issue[:included][0][:relationships].merge!({
            replaces: { data: { type: 'risk_scores', id: RiskScore.last.id.to_s } }
          })

          post "/api/people/#{full_natural_person.id}/issues",
            params: issue,
            headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

          assert_replacement_issue_integrity(["RiskScoreSeed"])
          RiskScoreSeed.last.replaces.should == RiskScore.last
          RiskScoreSeed.first.replaces.should be_nil
          assert_response 201

          assert_logging(Issue.last, :create_entity, 1)
        end

        it 'creates a new issue with an allowance seed who wants to replace the current allowance' do
          full_natural_person = create(:full_natural_person)
          issue  = Api::IssuesHelper.issue_with_allowance_seed(ext, true)
          issue[:included][0][:relationships].merge!({
            replaces: { data: { type: 'allowances', id: Allowance.last.id.to_s } }
          })

          post "/api/people/#{full_natural_person.id}/issues",
            params: issue,
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
          full_natural_person = create(:full_natural_person)
          issue  = Api::IssuesHelper.issue_with_phone_seed(ext)
          issue[:included][0][:relationships].merge!({
            replaces: { data: { type: 'phones', id: Phone.last.id.to_s } }
          })

          post "/api/people/#{full_natural_person.id}/issues",
            params: issue,
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
          full_natural_person = create(:full_natural_person)
          issue  = Api::IssuesHelper.issue_with_email_seed(ext)
          issue[:included][0][:relationships].merge!({
            replaces: { data: { type: 'emails', id: Email.last.id.to_s } }
          })

          post "/api/people/#{full_natural_person.id}/issues",
            params: issue,
            headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

          Issue.count.should == 2
          EmailSeed.count.should == 2
          EmailSeed.last.issue.should == Issue.last
          EmailSeed.last.attachments.count.should == 1
          EmailSeed.last.replaces.should == Email.last
          EmailSeed.first.replaces.should be_nil
          assert_response 201

          assert_logging(Issue.last, :create_entity, 1)
        end

        it 'creates a new issue with an affinity seed who wants to replace the current affinity' do
          new_partner = create(:empty_person)
          full_natural_person = create(:full_natural_person)
          issue  = Api::IssuesHelper.issue_with_affinity_seed(new_partner, ext)
          issue[:included][0][:relationships].merge!({
            replaces: { data: { type: 'affinities', id: full_natural_person.affinities.reload.first.id.to_s } }
          })

          post "/api/people/#{full_natural_person.id}/issues",
            params: issue,
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
    end
  end

  describe 'Updating an issue' do
    it 'responds with 404 when issue does not exist' do
      person = create :full_natural_person
      patch "/api/people/#{person.id}/issues/#{Issue.last.id + 100}",
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }
      assert_response 404
>>>>>>> master
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

      assert_resource("issues", issue_id, api_response.data)
      r = api_response.data.relationships
      assert_resource("people", person.id, r.person.data)
      assert_resource("observations", observation_id, r.observations.data.first)
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
