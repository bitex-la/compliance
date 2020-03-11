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

  it_behaves_like 'max people allowed request limit',
    :issues,
    :full_approved_natural_person_issue

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

    it 'includes tags' do
      one = create(:basic_issue_with_tags)

      api_get "/issues"

      api_response.data.size.should == 1

      by_type = api_response.included
        .group_by{|i| i.type }
        .map{|a,b| [a, b.count ] }.to_h
        .should == {
          "tags"=>1,
          "people"=>1
        }
    end

    it 'when fetching issues do not include future issues' do
      current_issue = create(:basic_issue)
      future_issue = create(:future_issue)

      api_get "/issues"
      expect(api_response.data.size).to eq 1
      expect(api_response.data.first.id).to eq current_issue.id.to_s
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

    it 'creates a new issue with tags' do
      issue_tag = create(:issue_tag)
      
      expect do
        api_create('/issues', {
          type: 'issues',
          relationships: { 
            person: {data: {id: person.id, type: 'people'}},
            tags: {data: [{id: issue_tag.id, type: 'tags'}] },
          }
        })
      end.to change{Issue.count}.by(1)

      issue = Issue.find(api_response.data.id)
      expect(issue.tags).to include issue_tag

      api_get("/issues/#{issue.id}")
      expect(api_response.data.relationships.tags.data.first.id).to eq(issue_tag.id.to_s)
    end

    it 'updates an issue defer until' do
      issue = create(:basic_issue, defer_until: Date.today)

      defer_until = 1.day.from_now.to_date
      expect do
        api_update("/issues/#{issue.id}", {
          type: 'issues',
          id: issue.id,
          attributes: { defer_until: defer_until }
        })
      end.to change{issue.reload.defer_until}

      expect(issue.reload.defer_until).to eq defer_until
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
    end

    { complete: :draft,
      observe: :new,
      answer: :observed,
      dismiss: :new,
      reject: :new,
      abandon: :new
    }.each do |action, initial_state|
      it "It can #{action} issue" do
        issue = create(:basic_issue, 
          state: initial_state, 
          person: person,
          workflows: [create(:basic_workflow)])

        api_request :post, "/issues/#{issue.id}/#{action}", {}, 200
      end
    end

    %i(complete observe answer dismiss reject abandon).each do |action|
      it "It cannot #{action} approved issue" do
        issue = create(:basic_issue, state: :approved, person: person)
        api_request :post, "/issues/#{issue.id}/#{action}", {}, 422
      end
    end

    it 'cannot approve issue if workflows are pending' do 
      issue = create(:basic_issue, person: person)

      2.times do 
        w = create(:basic_workflow, issue: issue)
        w.start!
      end

      api_request :post, "/issues/#{issue.id}/approve", {}, 422
      
      api_request :post, "/workflows/#{Workflow.first.id}/finish", {}, 200
      api_request :post, "/issues/#{issue.id}/approve", {}, 422
      
      api_request :post, "/workflows/#{Workflow.last.id}/finish", {}, 200
      api_request :post, "/issues/#{issue.id}/approve", {}, 200
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

      api_get "/issues/?filter[reason_code_eq]=further_clarification"
      api_response.data.map{|i| i.id.to_i}.to_set.should ==
        [one.id, two.id, three.id].to_set

      api_get "/issues/?filter[reason_code_eq]=invalid_code"
      expect(api_response.data).to be_empty
    end
  end

  describe 'locking issues' do
    it 'can lock issue if is not locked' do
      issue = create(:basic_issue)
      api_request :post, "/issues/#{issue.id}/lock", {}, 200
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
      
      api_request :post, "/issues/#{issue.id}/lock", {}, 422
      issue.reload
      expect(issue.locked).to be true
      expect(issue.lock_admin_user).to eq admin
    end

    it 'can unlock issue if is locked by me' do
      AdminUser.current_admin_user = create(:admin_user)

      issue = create(:basic_issue)
      expect(issue.lock_issue!).to be true
      expect(issue.locked).to be true

      api_request :post, "/issues/#{issue.id}/unlock", {}, 200
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
      
      api_request :post, "/issues/#{issue.id}/unlock", {}, 422
      issue.reload
      expect(issue.locked).to be true
      expect(issue.lock_admin_user).to eq admin
    end

    it 'can renew lock' do
      issue = create(:basic_issue)
      api_request :post, "/issues/#{issue.id}/lock", {}, 200
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


    it 'can lock issue with no expiration if is not locked' do
      issue = create(:basic_issue)
      api_request :post, "/issues/#{issue.id}/lock_for_ever", {}, 200
      issue.reload
      expect(issue.locked).to be true
      expect(issue.lock_expiration).to be_nil
    end

    it 'can not lock issue with expiration if it is locked with no expiration' do
      admin = create(:other_admin_user)
      AdminUser.current_admin_user = admin
      issue = create(:basic_issue)
      expect(issue.lock_issue!).to be true
      expect(issue.locked).to be true
      expect(issue.lock_admin_user).to eq admin

      create(:admin_user)
      
      api_request :post, "/issues/#{issue.id}/lock_for_ever", {}, 422
      issue.reload
      expect(issue.locked).to be true
      expect(issue.lock_admin_user).to eq admin
    end

    it 'can unlock issue with no expiration if it is locked by me' do
      AdminUser.current_admin_user = create(:admin_user)

      issue = create(:basic_issue)
      expect(issue.lock_issue!(false)).to be true
      expect(issue.locked).to be true

      api_request :post, "/issues/#{issue.id}/unlock", {}, 200
      issue.reload
      expect(issue.locked).to be false
    end

    it 'can lock issue if it is locked by another user and expired' do
      admin = create(:other_admin_user)
      AdminUser.current_admin_user = admin
      issue = create(:basic_issue)
      expect(issue.lock_issue!).to be true
      expect(issue.locked).to be true
      expect(issue.lock_admin_user).to eq admin

      other = create(:admin_user)
      
      Timecop.travel 1.day.from_now

      api_request :post, "/issues/#{issue.id}/lock", {}, 200
      issue.reload
      expect(issue.locked).to be true
      expect(issue.lock_admin_user).to eq other    
    end

    it 'can lock issue with no expiration if it is locked by another user and expired' do
      admin = create(:other_admin_user)
      AdminUser.current_admin_user = admin
      issue = create(:basic_issue)
      expect(issue.lock_issue!).to be true
      expect(issue.locked).to be true
      expect(issue.lock_admin_user).to eq admin

      other = create(:admin_user)
      
      Timecop.travel 1.day.from_now

      api_request :post, "/issues/#{issue.id}/lock_for_ever", {}, 200
      issue.reload
      expect(issue.locked).to be true
      expect(issue.lock_admin_user).to eq other
      expect(issue.lock_expiration).to be_nil
    end

    it 'can not unlock issue if it is locked by another user with no expiration' do
      admin = create(:other_admin_user)
      AdminUser.current_admin_user = admin
      issue = create(:basic_issue)
      expect(issue.lock_issue!(false)).to be true
      expect(issue.locked).to be true
      expect(issue.lock_admin_user).to eq admin

      other = create(:admin_user)
      
      api_request :post, "/issues/#{issue.id}/unlock", {}, 422
      issue.reload
      expect(issue.locked).to be true
      expect(issue.lock_admin_user).to eq admin
      expect(issue.lock_expiration).to be_nil
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
      api_request :post, "/issues/#{issue.id}/lock", {}, 200

      api_get("/issues/#{issue.id}")
      
      interval = Issue.lock_expiration_interval_minutes

      expect(api_response.data.attributes.locked).to eq true
      expect(DateTime.parse(api_response.data.attributes.lock_expiration)).to eq interval.from_now
    end
  end

  describe "When filter by admin tags" do
    let(:admin_user) { create(:admin_user) }

    before :each do
      admin_user.tags.clear
      admin_user.save!
    end

    it "allow issue creation only with person valid admin tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:alt_full_person_tagging).person

      admin_user.tags << person1.tags.first
      admin_user.save!

      expect do
        api_create('/issues',
          type: 'issues',
          relationships: { person: {
            data: { id: person1.id, type: 'people' }
          } })
      end.to change { Issue.count }.by(1)

      issue = Issue.last
      expect(api_response.data.id).to eq(issue.id.to_s)

      expect do
        api_create('/issues', {
          type: 'issues',
          relationships: { person: {
            data: { id: person2.id, type: 'people' }
          } }
        }, 404)
      end.to change { Issue.count }.by(0)

      expect(issue).to eq(Issue.last)

      admin_user.tags << person2.tags.first
      admin_user.save!

      expect do
        api_create('/issues',
          type: 'issues',
          relationships: { person: {
            data: { id: person1.id, type: 'people' }
          } })
      end.to change { Issue.count }.by(1)

      issue = Issue.last
      expect(api_response.data.id).to eq(issue.id.to_s)

      expect do
        api_create('/issues',
          type: 'issues',
          relationships: { person: {
            data: { id: person2.id, type: 'people' }
          } })
      end.to change { Issue.count }.by(1)

      issue = Issue.last
      expect(api_response.data.id).to eq(issue.id.to_s)
    end

    it "allow issue creation with person tags if admin has no tags" do
      person = create(:full_person_tagging).person

      expect do
        api_create('/issues',
          type: 'issues',
          relationships: { person: {
            data: { id: person.id, type: 'people' }
          } })
      end.to change { Issue.count }.by(1)
    end

    it "allow issue creation without person tags if admin has no tags" do
      person = create(:empty_person)

      expect do
        api_create('/issues',
          type: 'issues',
          relationships: { person: {
            data: { id: person.id, type: 'people' }
          } })
      end.to change { Issue.count }.by(1)
    end

    it "allow issue creation without person tags if admin has tags" do
      person = create(:full_person_tagging).person

      admin_user.tags << person.tags.first
      admin_user.save!

      expect do
        api_create('/issues',
          type: 'issues',
          relationships: { person: {
            data: { id: person.id, type: 'people' }
          } })
      end.to change { Issue.count }.by(1)
    end

    it "Update a person with person tags if admin has tags" do
      issue1, issue2, issue3, issue4 = setup_for_admin_tags_spec
      person1 = issue1.person
      person3 = issue3.person

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_update "/issues/#{issue1.id}",
        type: 'issues',
        id: issue1.id,
        attributes: { reason: IssueReason.update_expired_data }

      api_update "/issues/#{issue2.id}",
        type: 'issues',
        id: issue2.id,
        attributes: { reason: IssueReason.update_expired_data }

      api_update "/issues/#{issue3.id}", {
        type: 'issues',
        id: issue3.id,
        attributes: { reason: IssueReason.update_expired_data }
      }, 404

      api_update "/issues/#{issue4.id}",
        type: 'issues',
        id: issue4.id,
        attributes: { reason: IssueReason.update_expired_data }

      admin_user.tags << person3.tags.first
      admin_user.save!

      api_update "/issues/#{issue3.id}", {
        type: 'issues',
        id: issue3.id,
        attributes: { reason: IssueReason.update_expired_data }
      }
    end

    it "show issue with admin user active tags" do
      issue1, issue2, issue3, issue4 = setup_for_admin_tags_spec
      person1 = issue1.person
      person3 = issue3.person

      api_get("/issues/#{issue1.id}")
      api_get("/issues/#{issue2.id}")
      api_get("/issues/#{issue3.id}")
      api_get("/issues/#{issue4.id}")

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/issues/#{issue1.id}")
      api_get("/issues/#{issue2.id}")
      api_get("/issues/#{issue3.id}", {}, 404)
      api_get("/issues/#{issue4.id}")

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      api_get("/issues/#{issue1.id}", {}, 404)
      api_get("/issues/#{issue2.id}")
      api_get("/issues/#{issue3.id}")
      api_get("/issues/#{issue4.id}")

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/issues/#{issue1.id}")
      api_get("/issues/#{issue2.id}")
      api_get("/issues/#{issue3.id}")
      api_get("/issues/#{issue4.id}")
    end

    it "index issue with admin user active tags" do
      issue1, issue2, issue3, issue4 = setup_for_admin_tags_spec
      person1 = issue1.person
      person3 = issue3.person

      api_get("/issues/", page: { page: 0, per_page: 4 })

      expect(api_response.meta.total_items).to eq(4)
      expect(api_response.data[0].id).to eq(issue4.id.to_s)
      expect(api_response.data[1].id).to eq(issue3.id.to_s)
      expect(api_response.data[2].id).to eq(issue2.id.to_s)
      expect(api_response.data[3].id).to eq(issue1.id.to_s)

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/issues/", page: { page: 0, per_page: 4 })
      expect(api_response.meta.total_items).to eq(3)
      expect(api_response.data[0].id).to eq(issue4.id.to_s)
      expect(api_response.data[1].id).to eq(issue2.id.to_s)
      expect(api_response.data[2].id).to eq(issue1.id.to_s)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      api_get("/issues/", page: { page: 0, per_page: 4 })
      expect(api_response.meta.total_items).to eq(3)
      expect(api_response.data[0].id).to eq(issue4.id.to_s)
      expect(api_response.data[1].id).to eq(issue3.id.to_s)
      expect(api_response.data[2].id).to eq(issue2.id.to_s)

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/issues/", page: { page: 0, per_page: 4 })
      expect(api_response.meta.total_items).to eq(4)
      expect(api_response.data[0].id).to eq(issue4.id.to_s)
      expect(api_response.data[1].id).to eq(issue3.id.to_s)
      expect(api_response.data[2].id).to eq(issue2.id.to_s)
      expect(api_response.data[3].id).to eq(issue1.id.to_s)
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

      [issue1, issue2, issue3, issue4]
    end
  end
end
