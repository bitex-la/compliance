require 'rails_helper'

RSpec.describe Person, type: :model do  
  it 'is valid without issues' do
    expect(Person.new).to be_valid
  end

  it 'knows which fruits can be replaced' do
    person =  create(:full_natural_person)
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
    person = create(:full_natural_person, enabled: false)
    assert_logging(person, :enable_person, 0)
    2.times do
      person.update(enabled: true)
    end
    assert_logging(person, :enable_person, 1)
    2.times do
      person.update(enabled: false)
    end
    assert_logging(person, :disable_person, 1)
  end 
  
  it 'shows only observations for meaningful issues' do 
    person = create(:full_natural_person)
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

  describe 'looking for suggestions' do
    it 'search a person by id, first name, last name, email, phone and identification' do
      person = create(:full_natural_person)

      expect(Person.suggest('1').first)
        .to include({:id=>1, :suggestion=>"人 1: Joe Doe - 1"})

      expect(Person.suggest('Joe').first)
        .to include({:id=>1, :suggestion=>"人 1: Joe Doe - Joe - Doe"})

      expect(Person.suggest('Johnny')).to be_empty
      
      email_to_search = Email.first.address  
      expect(Person.suggest(email_to_search).first)
        .to include({:id=>1, :suggestion=>"人 1: Joe Doe - #{email_to_search}"})
      
      expect(Person.suggest('not_a_faker_email@test.com')).to be_empty

      expect(Person.suggest('1125410470').first)
        .to include({:id=>1, :suggestion=>"人 1: Joe Doe - +5491125410470"})

      expect(Person.suggest('2545566').first)
        .to include({:id=>1, :suggestion=>"人 1: Joe Doe - 2545566"})

      expect(Person.suggest('80932388')).to be_empty
    end
  end
end
