require 'rails_helper'

describe Issue do
  let(:person) { create(:empty_person) }

  it_behaves_like 'jsonapi show and index',
    :issues,
    :basic_issue,
    :full_approved_natural_person_issue,
    {state_eq: 'approved'},
    'domicile_seeds,person',
    'identification_seeds,domicile_seeds',
    -> { {} }, [3, 4, 2], 4, 4

  describe 'When fetching issues' do
    it 'includes relationships for all issues' do
      one = create(:full_natural_person).reload.issues.first
      two = create(:basic_issue)

      api_get "/issues"

      api_response.data.size.should == 3

      by_type = api_response.included
        .group_by{|i| i.type }
        .map{|a,b| [a, b.count ] }.to_h
        .should == {
          "attachments"=>66, 
          "email_seeds"=>2, 
          "emails"=>2, 
          "identification_seeds"=>2, 
          "identifications"=>2, 
          "natural_docket_seeds"=>2, 
          "natural_dockets"=>2, 
          "people"=>3
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

      issue = Issue.find(api_response.data.id) 

      assert_logging(Issue.last, :create_entity, 1)

      expect do
        api_create('/observations', {
          type: 'observations',
          attributes: {note: 'Observation Note', scope: 'admin'},
          relationships: {
            issue: {data: {type: 'issues', id: issue.id }},
            observation_reason: {
              data: {type: 'observation_reasons', id: reason.id}
            }
          }
        })
      end.to change{ Observation.count }.by(1)
      observation_id = api_response.data.id

      assert_logging(issue.observations.last, :create_entity, 1)
      assert_logging(issue.reload, :observe_issue, 1)

      api_get("/issues/#{issue.id}")

      api_response.data.attributes.state.should == 'observed'
      api_response.data.relationships.observations
        .data.first.id.should == observation_id
      api_response.included.select{|o| o.type == 'observations'}
        .map(&:id).should == [observation_id]
    end

    it 'creates a new issue with defer until' do
      defer_until = 1.month.from_now.to_date
      
      expect do
        api_create('/issues', {
          type: 'issues',
          attributes: {defer_until: defer_until},
          relationships: { person: {data: {id: person.id, type: 'people'}}}
        })
      end.to change{Issue.count}.by(1)

      issue = Issue.find(api_response.data.id)
      expect(issue.defer_until).to eq(defer_until)

      api_get("/issues/#{issue.id}")
      
      expect(Date.parse(api_response.data.attributes.defer_until)).to eq(defer_until)
    end

    it 'creates a new issue with custom reason' do  
      expect do
        api_create('/issues', {
          type: 'issues',
          attributes: {reason_code: IssueReason.new_client.code},
          relationships: { person: {data: {id: person.id, type: 'people'}}}
        })
      end.to change{Issue.count}.by(1)

      issue = Issue.find(api_response.data.id)
      expect(issue.reason).to eq(IssueReason.new_client)

      api_get("/issues/#{issue.id}")
      
      expect(api_response.data.attributes.reason_code).to eq(IssueReason.new_client.code.to_s)
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

  describe 'locking issues' do
    it 'can lock issue if is not locked' do
      issue = create(:basic_issue)
      api_request :post, "/issues/#{issue.id}/lock_issue", {}, 200
      issue.reload
      expect(issue.locked).to be true
    end

    it 'can not lock issue if is locked by another user' do
      admin = create(:other_admin_user)
      AdminUser.current_admin_user = admin
      issue = create(:basic_issue)
      expect(issue.lock_issue!).to be true
      expect(issue.locked).to be true
      expect(issue.lock_admin_user).to eq admin

      create(:admin_user)
      
      api_request :post, "/issues/#{issue.id}/lock_issue", {}, 422
      issue.reload
      expect(issue.locked).to be true
      expect(issue.lock_admin_user).to eq admin
    end

    it 'can unlock issue if is locked by me' do
      AdminUser.current_admin_user = create(:admin_user)

      issue = create(:basic_issue)
      expect(issue.lock_issue!).to be true
      expect(issue.locked).to be true

      api_request :post, "/issues/#{issue.id}/unlock_issue", {}, 200
      issue.reload
      expect(issue.locked).to be false
    end

    it 'can not unlock issue if is locked by another user' do
      admin = create(:other_admin_user)
      AdminUser.current_admin_user = admin
      issue = create(:basic_issue)
      expect(issue.lock_issue!).to be true
      expect(issue.locked).to be true
      expect(issue.lock_admin_user).to eq admin

      create(:admin_user)
      
      api_request :post, "/issues/#{issue.id}/unlock_issue", {}, 422
      issue.reload
      expect(issue.locked).to be true
      expect(issue.lock_admin_user).to eq admin
    end

    it 'can renew lock' do
      issue = create(:basic_issue)
      api_request :post, "/issues/#{issue.id}/lock_issue", {}, 200
      issue.reload
      expect(issue.locked).to be true

      api_request :post, "/issues/#{issue.id}/renew_lock", {}, 200
      issue.reload
      expect(issue.locked).to be true
    end

    it 'can not renew lock if is locked by another user' do
      admin = create(:other_admin_user)
      AdminUser.current_admin_user = admin
      issue = create(:basic_issue)
      expect(issue.lock_issue!).to be true
      expect(issue.locked).to be true
      expect(issue.lock_admin_user).to eq admin

      create(:admin_user)
      
      api_request :post, "/issues/#{issue.id}/renew_lock", {}, 422
      issue.reload
      expect(issue.locked).to be true
      expect(issue.lock_admin_user).to eq admin
    end

    it 'fetch issue with locking information' do
      expect do
        api_create('/issues', {
          type: 'issues',
          attributes: {},
          relationships: { person: {data: {id: person.id, type: 'people'}}}
        })
      end.to change{Issue.count}.by(1)

      issue = Issue.find(api_response.data.id)

      Timecop.freeze DateTime.new(2018,01,01,13,0,0)
      api_request :post, "/issues/#{issue.id}/lock_issue", {}, 200

      api_get("/issues/#{issue.id}")
      
      interval = Settings.lock_issues.expiration_interval_minutes.minutes

      expect(api_response.data.attributes.locked).to eq true
      expect(DateTime.parse(api_response.data.attributes.lock_expiration)).to eq interval.from_now
    end
  end
end
