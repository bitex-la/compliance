require 'rails_helper'

RSpec.describe Issue, type: :model do
  let(:invalid_issue) { described_class.new } 
  let(:empty_issue) { create(:basic_issue) }
  let(:basic_issue) { create(:basic_issue) }

  it 'is not valid without a person' do
    expect(invalid_issue).to_not be_valid
  end

  it 'is valid with a person' do
    expect(basic_issue).to be_valid
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

    it 'disables person on reject' do
      person = create :full_natural_person
      issue = create(:basic_issue, person: person)
      
      expect do
        issue.reject!
      end.to change{ person.enabled }.to(false)
    end

    it 'does nothing on dismiss' do
      person = create :full_natural_person
      issue = create(:basic_issue, person: person)
      
      expect do
        issue.dismiss!
      end.not_to change{ person.enabled }
    end

    it 'enables person on approve' do
      person = create :new_natural_person
      
      expect do
        person.issues.reload.last.approve!
      end.to change{ person.enabled }.to(true)
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

      Timecop.travel 1.minutes.from_now
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

      Timecop.travel 1.minutes.from_now
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
end
