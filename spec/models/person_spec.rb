require 'rails_helper'

RSpec.describe Person, type: :model do
  let(:person) { create(:full_natural_person) }
  let(:empty_person){ create(:empty_person) }

  it 'is valid without issues' do
    expect(Person.new).to be_valid
  end

  it 'knows which fruits can be replaced' do
    new_phone = create :full_phone, person: person
    person.reload.phones.first.update(replaced_by: new_phone)

    person.reload.replaceable_fruits.sort_by{|i| [i.class.name, i.id]}.should == [
      Allowance.first,
      Allowance.last,
      ArgentinaInvoicingDetail.first,
      Domicile.first,
      Email.first,
      Identification.first,
      NaturalDocket.first,
      Phone.last,
    ]
  end

  it 'Add state changes to event log when enable/disable' do 
    person = create(:empty_person)
    assert_logging(person, :enable_person, 0)
    expect(person).to have_state(:new)
    2.times do
      person.update(enabled: true)
    end
    assert_logging(person, :enable_person, 1)
    expect(person).to have_state(:all_clear)
    2.times do
      person.update(enabled: false)
    end
    assert_logging(person, :disable_person, 1)
    expect(person).to have_state(:must_wait)
  end 
  
  it 'shows only observations for meaningful issues' do 
    one = create(:basic_issue, person: person)
    two = create(:basic_issue, person: person)
    three = create(:basic_issue, person: person)

    worldcheck_observation = create(:admin_world_check_observation, issue: one)
    risk_observation = create(:chainalysis_observation, issue: two)
    robot_observation = create(:robot_observation, issue: three)

    person.all_observations.count.should == 3
    
    one.dismiss!
    two.abandon!

    person.all_observations.to_a.should == [robot_observation]
  end

  describe 'when transitioning' do 
    it 'defaults to new' do 
      expect(empty_person).to have_state(:new)
    end

    %i(unknown new must_reply must_wait all_clear).each do |state|
      it "goes from #{state} to can_reply on reply_as_enabled" do 
        expect(person).to transition_from(state).to(:can_reply).on_event(:reply_as_enabled)
      end
    end

    %i(unknown new all_clear must_wait).each do |state|
      it "goes from #{state} to must_reply on reply_as_disabled" do 
        expect(person).to transition_from(state).to(:must_reply).on_event(:reply_as_disabled)
      end
    end

    %i(unknown new all_clear must_reply can_reply).each do |state|
      it "goes from #{state} to must_wait on wait_for_approval" do 
        expect(person).to transition_from(state).to(:must_wait).on_event(:wait_for_approval)
      end
    end

    %i(unknown new can_reply must_reply must_wait).each do |state|
      it "goes from #{state} to all_clear on promote" do 
        expect(person).to transition_from(state).to(:all_clear).on_event(:promote)
      end
    end

    it 'goes to must_wait if person is disabled' do 
      expect(person).to have_state(:all_clear)
      person.update!(enabled: false)

      expect(person).to have_state(:must_wait)

      person.update(enabled: true)
      expect(person).to have_state(:all_clear)
    end

    it 'goes to must_wait if person issue is rejected' do
      person = create(:empty_person)
      issue = create(:full_natural_person_issue, person: person)
      issue.reject!

      expect(person).to have_state(:must_wait)

      person.update(enabled: true)
      expect(person).to have_state(:all_clear)
    end
  end

  describe 'when calculate status from unknown state' do 
    it 'goes from unknown to can reply if applies' do 
      person.update_column('aasm_state', 'unknown')
      issue = create(:basic_issue, person: person)
      observation = create(:observation, issue: issue)
      person.reload.sync_status!
      
      expect(person).to have_state(:can_reply)
    end

    it 'goes from unknown to all_clear if applies' do 
      person.update_column('aasm_state', 'unknown')
      person.reload.sync_status!
      
      expect(person).to have_state(:all_clear)
    end

    it 'goes from unknown to new if applies' do 
      person = create(:empty_person)
      person.update_column('aasm_state', 'unknown')
      person.reload.sync_status!

      expect(person).to have_state(:new)
    end

    it 'goes from unknown to must_reply if applies' do
      person = create(:empty_person)
      person.update_column('aasm_state', 'unknown')
      issue = create(:full_natural_person_issue, person: person)
      create(:observation, issue: issue)
      person.reload.sync_status!

      expect(person).to have_state(:must_reply)
    end

    it 'goes from unknown to must_wait if applies' do
      person = create(:empty_person)
      person.update_column('aasm_state', 'unknown')
      issue = create(:full_natural_person_issue, person: person)
      create(:observation, issue: issue, reply: 'Please check!!')
      person.reload.sync_status!

      expect(person).to have_state(:must_wait)
    end

    it 'goes from unknown to must reply even if issue state is answered' do 
      person = create(:empty_person)
      person.update_column('aasm_state', 'unknown')
      issue = create(:full_natural_person_issue, person: person)
      create(:observation, issue: issue)
      create(:robot_observation, issue: issue)
      create(:admin_world_check_observation, issue: issue)
      create(:chainalysis_observation, issue: issue)
      issue.reload.update_column('aasm_state', 'answered')

      person.reload.sync_status!

      expect(person).to have_state(:must_reply)
    end
  end
end
