require 'rails_helper'

RSpec.describe Issue, type: :model do
  let(:invalid_issue) { described_class.new } 
  let(:empty_issue) { create(:basic_issue) }
  let(:basic_issue) { create(:basic_issue) }
  let(:future_issue) { create(:future_issue) }
  let(:invalid_future_issue) { described_class.new(person: create(:empty_person),
    defer_until: Date.today - 1.days) }

  it 'is not valid without a person' do
    expect(invalid_issue).to_not be_valid
  end

  it 'is valid with a person' do
    expect(basic_issue).to be_valid
  end

  it 'is valid future issue' do
    expect(future_issue).to be_valid
  end

  it 'is not valid future issue when defer until is less than creation date' do
    expect(invalid_future_issue).to_not be_valid
  end

  it 'has a default further_clarification reason' do
    issue = create(:basic_issue)
    expect(issue.reason).to eq(IssueReason.further_clarification)
  end

  it 'respect selected reason' do
    issue = create(:basic_issue, reason: IssueReason.new_client)
    expect(issue.reason).to eq(IssueReason.new_client)
  end

  it 'is not allow to change reason' do
    issue = create(:basic_issue, reason: IssueReason.new_client)
    issue.reason = IssueReason.further_clarification
    expect(issue).to_not be_valid
    expect(issue.errors.messages).to include :reason
  end

  it 'it moves from future to current scope' do
    expect(Issue.future).to include future_issue
    expect(Issue.current).to_not include future_issue
    expect(Issue.draft).to_not include future_issue
    expect(Issue.fresh).to_not include future_issue

    Timecop.travel 3.months.from_now
  
    expect(Issue.future).to_not include future_issue
    expect(Issue.current).to include future_issue
    expect(Issue.draft).to include future_issue
    expect(Issue.fresh).to_not include future_issue
  end

  it 'is in natural scope' do
    issue = create(:full_approved_natural_person_issue)
    expect(Issue.by_person_type("natural")).to include issue
    expect(Issue.by_person_type("legal")).to_not include issue
  end

  it 'new person with natural docket seed is in natural scope' do
    issue = create(:new_natural_person_issue)
    expect(Issue.by_person_type("natural")).to include issue
    expect(Issue.by_person_type("legal")).to_not include issue
  end

  it 'is in legal scope' do
    issue = create(:full_approved_legal_entity_issue)
    expect(Issue.by_person_type("natural")).to_not include issue
    expect(Issue.by_person_type("legal")).to include issue
  end

  it 'is not valid issue when expires at is less than creation date' do
    empty_issue.note_seeds.create(title:'title', body: 'body', expires_at: 1.month.ago)
    expect(empty_issue).to_not be_valid
    expect(empty_issue.errors.messages.keys.first).to eq(:"note_seeds.expires_at")
  end

  describe 'when transitioning' do
    it 'defaults to draft' do
      expect(empty_issue).to have_state(:draft)
    end

    it "goes from draft to new on complete" do
      expect(empty_issue).to transition_from(:draft).to(:new).on_event(:complete)
    end

    %i(draft new answered).each do |state|
      it "goes from #{state} to observed on observe" do
        expect(empty_issue).to transition_from(state).to(:observed).on_event(:observe)
      end
    end

    %i(observed).each do |state|
      it "goes from #{state} to answered on answer" do
        expect(empty_issue).to transition_from(state).to(:answered).on_event(:answer)
      end
    end

    %i(new answered observed).each do |state|
      it "goes from #{state} to dismissed on dismiss" do
        expect(empty_issue).to transition_from(state).to(:dismissed).on_event(:dismiss)
      end
    end

    %i(new observed answered).each do |state|
      it "goes from #{state} to rejected on reject" do
        expect(empty_issue).to transition_from(state).to(:rejected).on_event(:reject)
      end
    end

    %i(new answered).each do |state|
      it "goes from #{state} to approved on approve" do
        expect(empty_issue).to transition_from(state).to(:approved).on_event(:approve) 
      end
    end

    %i(new observed answered).each do |state|
      it "goes from #{state} to abandoned on abandon" do
        expect(empty_issue).to transition_from(state).to(:abandoned).on_event(:abandon)
      end
    end

    it 'does nothing on reject' do
      person = create :full_natural_person
      issue = create(:basic_issue, person: person)
      
      expect do
        issue.reject!
      end.not_to change{ person.enabled }
    end

    it 'does nothing on dismiss' do
      person = create :full_natural_person
      issue = create(:basic_issue, person: person)
      
      expect do
        issue.dismiss!
      end.not_to change{ person.enabled }
    end

    it 'do not enable person on approve' do
      person = create :new_natural_person
      
      person.issues.reload.last.approve!
      expect(person.enabled).to be_falsey
    end

    it 'creates deferred issues for each expiring seed' do
      person = create :empty_person
      issue = person.issues.create
      expires_at = 1.month.from_now.to_date
      issue.note_seeds.create(title:'title', body: 'body', expires_at:expires_at)
      issue.risk_score_seeds.create(score:'score', expires_at:expires_at)
    
      issue.save!

      expect(person.issues.to_a).to eq([issue])

      expect do
        issue.approve!
      end.to change{person.issues.count}.by(2)      
      
      person.reload

      issue_notes = person.issues[-2]
      expect(issue_notes).to_not be(issue)
      expect(issue_notes.defer_until).to eq(expires_at)
      expect(issue_notes.note_seeds.first.title).to eq('title')
      expect(issue_notes.note_seeds.first.body).to eq('body')

      risk_issue = person.issues.last
      expect(risk_issue).to_not be(issue)
      expect(risk_issue.defer_until).to eq(expires_at)
      expect(risk_issue.risk_score_seeds.first.score).to eq('score')
    
      expect(risk_issue.risk_score_seeds.first.replaces).to eq(person.risk_scores.first)
    end
  end

  describe "when transitioning" do
    it 'creates new fruits for new person' do
      person = create :new_natural_person
      issue = person.issues.reload.last
      %i(domiciles natural_dockets allowances identifications).each do |assoc|
        person.send(assoc).should be_empty
      end
      issue.approve!
      person.reload
      issue.reload

      %w(domicile natural_docket allowance identification).each do |assoc|
        person.send(assoc.pluralize).should_not be_empty
      end

      %w(domicile allowance identification).each do |assoc|
        person.send(assoc.pluralize).first.seed.should ==
          issue.send("#{assoc}_seeds").first
        issue.send("#{assoc}_seeds").first.fruit.should == 
          person.send(assoc.pluralize).first
      end

      person.natural_dockets.first.seed.should == issue.natural_docket_seed
      issue.natural_docket_seed.fruit.should == person.natural_dockets.first

      # Allowance
      fruit = person.allowances.first
  
      %i(weight amount kind).each do |attr|
        fruit.send(attr).should == fruit.seed.send(attr)
      end
    end

    it 'adds some new fruits and replace others on existing person' do
      person = create(:full_natural_person).reload
      issue = create :basic_issue, person: person

      issue.add_seeds_replacing([person.domiciles.last])

      create :salary_allowance_seed, issue: issue
      create :full_natural_docket_seed, issue: issue

      issue.reload
      issue.complete!
      issue.should be_new
      issue.approve!
      issue.should be_approved
      issue.domicile_seeds.count.should == 1
      issue.allowance_seeds.count.should == 1
      issue.natural_docket_seed.should_not be_nil
      issue.legal_entity_docket_seed.should be_nil
      person.reload
      person.domiciles.count.should == 1
      person.domiciles.current.count.should == 1
      person.natural_dockets.count.should == 1
      person.natural_dockets.current.count.should == 1
      person.allowances.count.should == 3
      person.allowances.current.count.should == 3

      person.natural_docket.tap do |d|
        d.should == person.natural_dockets.current.last
      end
    end

    it "cannot try to replace a different person's fruit" do
      person = create(:full_natural_person).reload
      other_person = create(:full_natural_person).reload
      issue = create :basic_issue, person: person

      issue.add_seeds_replacing([other_person.domiciles.last])
      issue.reload.domicile_seeds.should be_empty
    end
  end  

  describe "when snapping in and out of observed state" do
    it 'can snap into observed state' do
      issue = create(:full_natural_person_issue, person: create(:empty_person))
      obs = create(:observation, issue: issue)
      issue.reload.should be_observed
      issue.update_column(:aasm_state, 'new')
      issue.reload.should be_new
      issue.save
      issue.reload.should be_observed
      obs.update(reply: 'replied')
      issue.reload.should be_answered
    end

    it 'can snap out of faulty observed state' do
      issue = create(:full_natural_person_issue, person: create(:empty_person))
      create(:observation, issue: issue, reply: "replied")
      issue.update_column(:aasm_state, 'observed')
      issue.reload.should be_observed
      issue.save
      issue.should be_answered
    end

    it 'can go directly into answered state from draft' do
      issue = create(:full_natural_person_issue, person: create(:empty_person))
      create(:observation, issue: issue, reply: "replied")
      issue.reload.should be_answered
    end

    it 'creates an observe_issue event anytime that issue gets new observations' do
      issue = create(:full_natural_person_issue, person: create(:empty_person))
      obs = create(:observation, issue: issue)
      issue.reload.should be_observed
      assert_logging(issue, :observe_issue, 1)

      Timecop.travel 1.second.from_now
      3.times do
        create(:observation, issue: issue)
      end
      issue.reload.should be_observed
      issue.save
      assert_logging(issue.reload, :observe_issue, 2)

      obs = issue.observations.last
      obs.update(reply: 'check out the reply')
      issue.reload.should be_observed
      issue.save
      assert_logging(issue.reload, :observe_issue, 2)

      Timecop.travel 1.second.from_now
      issue.update_column(:aasm_state, 'answered')
      create(:observation, issue: issue)
      issue.reload.should be_observed
      assert_logging(issue, :observe_issue, 3)
    end
  end

  describe "when looking for people who had problems answering" do
    it 'has a scope for changed_after_observation' do
      issue = create(:full_natural_person_issue, person: create(:empty_person))
      create(:observation, issue: issue)
      issue.reload.should be_observed

      Issue.changed_after_observation.size.should == 0
      Timecop.travel 10.minutes.from_now
      issue.domicile_seeds.first.update(street_address: "Something")
      Issue.changed_after_observation.count.should == 1
    end

    it 'ignores answered issues' do
      issue = create(:full_natural_person_issue, person: create(:empty_person))
      create(:observation, issue: issue, reply: 'text')

      Issue.changed_after_observation.size.should == 0

      Timecop.travel 10.minutes.from_now
      issue.domicile_seeds.first.update(street_address: "Something")

      Timecop.travel 10.minutes.from_now
      create(:observation, issue: issue)

      Issue.changed_after_observation.size.should == 0

      Timecop.travel 10.minutes.from_now
      issue.domicile_seeds.first.update(street_address: "Something else")
      Issue.changed_after_observation.size.should == 1
    end
  end

  describe "when locks and unlock issues" do
    let(:admin_user) { create(:admin_user) }
    let(:other_admin_user) { create(:other_admin_user) }

    interval = Issue.lock_expiration_interval_minutes

    before :each do 
      AdminUser.current_admin_user = admin_user 
    end
    
    it 'can lock issue if not locked' do
      Timecop.freeze DateTime.new(2018,01,01,13,0,0)
      expect(basic_issue.lock_issue!).to be true
      expect(basic_issue.locked).to be true
      expect(basic_issue.lock_admin_user).to eq admin_user
      expect(basic_issue.lock_expiration).to eq interval.from_now
    end

    it 'multiple locks not change expiration' do
      Timecop.freeze DateTime.new(2018,01,01,13,0,0)
      expect(basic_issue.lock_issue!).to be true
      expect(basic_issue.locked).to be true
      expect(basic_issue.lock_admin_user).to eq admin_user
      expect(basic_issue.lock_expiration).to eq interval.from_now

      expect(basic_issue.lock_issue!).to be true
      expect(basic_issue.locked).to be true
      expect(basic_issue.lock_admin_user).to eq admin_user
      expect(basic_issue.lock_expiration).to eq interval.from_now
    end

    it 'can lock issue if it is locked by other user and expired' do
      Timecop.freeze DateTime.new(2018,01,01,13,0,0)

      expect(basic_issue.lock_issue!).to be true

      Timecop.freeze DateTime.new(2018,01,01,13,20,0)

      AdminUser.current_admin_user = other_admin_user

      expect(basic_issue.lock_issue!).to be true
      expect(basic_issue.locked).to be true
      expect(basic_issue.lock_admin_user).to eq other_admin_user
      expect(basic_issue.lock_expiration).to eq interval.from_now
    end

    it 'can not lock issue if is locked by other user and not expired' do
      Timecop.freeze DateTime.new(2018,01,01,13,0,0)

      expect(basic_issue.lock_issue!).to be true

      lock_expiration = basic_issue.lock_expiration

      Timecop.freeze DateTime.new(2018,01,01,13,5,0)

      AdminUser.current_admin_user = other_admin_user

      expect(basic_issue.lock_issue!).to be false
      expect(basic_issue.locked).to be true
      expect(basic_issue.lock_admin_user).to eq admin_user
      expect(basic_issue.lock_expiration).to eq lock_expiration
    end

    it 'can unlock issue if is locked by me and not expired' do
      expect(basic_issue.lock_issue!).to be true
      Timecop.travel 5.minutes.from_now
      expect(basic_issue.unlock_issue!).to be true
      expect(basic_issue.locked).to be false
      expect(basic_issue.lock_admin_user).to be nil
      expect(basic_issue.lock_expiration).to be nil
    end

    it 'can not unlock issue if is locked by me and expired' do
      expect(basic_issue.lock_issue!).to be true
      Timecop.travel 20.minutes.from_now
      expect(basic_issue.unlock_issue!).to be false
    end

    it 'can renew lock if is locked by me and not expired' do
      Timecop.freeze DateTime.new(2018,01,01,13,0,0)
      expect(basic_issue.lock_issue!).to be true
      Timecop.freeze DateTime.new(2018,01,01,13,10,0)
      expect(basic_issue.renew_lock!).to be true
      expect(basic_issue.lock_expiration).to eq interval.from_now
    end

    it 'can not renew lock if is locked by me and expired' do
      expect(basic_issue.lock_issue!).to be true
      Timecop.travel (interval + 1.minutes).from_now
      expect(basic_issue.renew_lock!).to be false
    end

    it 'can not save changes if locked by another user' do
      expect(basic_issue.lock_issue!).to be true
      AdminUser.current_admin_user = other_admin_user
      basic_issue.defer_until = DateTime.now
      expect(basic_issue).to_not be_valid
      expect(basic_issue.errors.messages[:issue].first).to eq "changes in locked issues are not allowed!"
    end

    it 'can save changes if locked by another user and expired' do
      expect(basic_issue.lock_issue!).to be true
      Timecop.travel (interval + 1.minutes).from_now
      AdminUser.current_admin_user = other_admin_user
      defer = Date.today + 20.days
      basic_issue.defer_until = defer
      expect(basic_issue).to be_valid
      basic_issue.save!
      expect(basic_issue.defer_until).to eq defer
    end

    it 'save changes if locked by me user and not expired' do
      expect(basic_issue.lock_issue!).to be true
      Timecop.travel (interval + 1.minutes).from_now
      defer = Date.today + 20.days
      basic_issue.defer_until = defer
      expect(basic_issue).to be_valid
      basic_issue.save!
      expect(basic_issue.defer_until).to eq defer
    end
  end
end
