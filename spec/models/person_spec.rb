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

  describe 'when transitioning happens' do
    it 'defaults to new after create' do 
      expect(empty_person).to have_state(:new) 
    end

    %i(unknown new must_wait can_reply).each do |state|
      it "goes from #{state} to all_clear on enable" do
        expect(empty_person).to transition_from(state).to(:all_clear).on_event(:enable)
      end
    end

    %i(all_clear must_reply can_reply new).each do |state|
      it "goes from #{state} to must_wait on disable" do
        expect(empty_person).to transition_from(state).to(:must_wait).on_event(:disable)
      end
    end
  end
end
