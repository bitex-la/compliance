require 'rails_helper'

RSpec.describe Person, type: :model do
  let(:person) { create(:full_natural_person) }
  let(:empty_person) { create(:empty_person) }

  it 'is valid without issues' do
    expect(Person.new).to be_valid
  end

  it 'starts as none regularity' do
    expect(Person.new.regularity).to eq PersonRegularity.none
  end

  it "isn't in natural nor legal scope" do
    person = create(:empty_person)
    expect(Person.by_person_type("natural")).to_not include person
    expect(Person.by_person_type("legal")).to_not include person
  end

  it 'is in natural scope' do
    person = create(:full_natural_person)
    expect(Person.by_person_type("natural")).to include person
    expect(Person.by_person_type("legal")).to_not include person
  end

  it 'is in natural scope with issue' do
    issue = create(:new_natural_person_issue)
    person = issue.person
    expect(Person.by_person_type("natural")).to include person
    expect(Person.by_person_type("legal")).to_not include person
  end

  it 'is in legal scope' do
    person = create(:full_legal_entity_person)
    expect(Person.by_person_type("natural")).to_not include person
    expect(Person.by_person_type("legal")).to include person
  end

  it 'is in legal scope with issue' do
    issue = create(:new_legal_entity_issue)
    person = issue.person
    expect(Person.by_person_type("natural")).to_not include person
    expect(Person.by_person_type("legal")).to include person
  end

  it 'returns N/A person info' do
    person = create(:empty_person)
    expect(person.reload.person_info).to eq("(1)")
  end

  it 'returns natural person info with name, email, phone number and whatsapp from fruits' do
    person = create(:full_natural_person, :with_fixed_email)
    expect(person.reload.person_info).to eq("(1) ☺: Joe Doe ✉: admin@example.com ☎: +5491125410470 WA: ✓")
  end

  it 'returns natural person info with name, email, phone number and whatsapp from seeds' do
    person = create(:new_natural_person, :with_fixed_email)
    expect(person.reload.person_info).to eq("(1) *☺: Joe Doe *✉: admin@example.com *☎: +5491125410470 *WA: ✓")
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

    10.times { person.enable! rescue nil }
    assert_logging(person, :enable_person, 1)
    expect(person).to be_enabled
    expect(person.enabled).to eq(true) # Backwards compatible state

    10.times { person.disable! rescue nil }
    assert_logging(person, :disable_person, 1)
    expect(person).to be_disabled
    expect(person.enabled).to eq(false) # Backwards compatible state
  end

  it 'Add state changes to event log when state machine changes' do
    person = create(:empty_person)
    assert_logging(person, :person_new, 1)

    10.times { person.enable! }
    assert_logging(person, :person_enabled, 1)
    expect(person).to be_enabled
    expect(person.enabled).to eq(true) # Backwards compatible state

    10.times { person.disable! }
    assert_logging(person, :person_disabled, 1)
    expect(person).to be_disabled
    expect(person.enabled).to eq(false) # Backwards compatible state

    10.times { person.enable! }
    assert_logging(person, :person_enabled, 2)
    expect(person).to be_enabled
    expect(person.enabled).to eq(true) # Backwards compatible state

    10.times { person.reject! }
    assert_logging(person, :person_rejected, 1)
    expect(person).to be_rejected
    expect(person.enabled).to eq(false) # Backwards compatible state
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

  describe 'looking for suggestions' do
    it 'search a person by id, first name, last name, email, phone and identification' do
      
      person
    
      expect(Person.suggest('3').first)
        .to include({:id=>3, :suggestion=>"(3) ☺: Joe Doe - 3"})
      
      expect(Person.suggest('Joe').first)
        .to include({:id=>3, :suggestion=>"(3) ☺: Joe Doe - Joe - Doe"})

      expect(Person.suggest('Johnny')).to be_empty
      
      email_to_search = Email.first.address  
      expect(Person.suggest(email_to_search).first)
        .to include({:id=>1, :suggestion=>"(1) ☺: Joe Doe - #{email_to_search}"})
      
      expect(Person.suggest('not_a_faker_email@test.com')).to be_empty

      expect(Person.suggest('1125410470').first)
        .to include({:id=>1, :suggestion=>"(1) ☺: Joe Doe - +5491125410470"})

      expect(Person.suggest('2545566').first)
        .to include({:id=>3, :suggestion=>"(3) ☺: Joe Doe - 2545566"})

      expect(Person.suggest('80932388')).to be_empty
    end
  end

  describe 'when transitioning' do
    it 'defaults to new' do
      person = build(:empty_person)
      expect(person).to have_state(:new)
    end

    %i(new disabled enabled rejected).each do |state|
      it "goes from #{state} to enabled on enable" do
        expect(empty_person).to transition_from(state).to(:enabled).on_event(:enable)
      end
    end

    %i(new enabled disabled rejected).each do |state|
      it "goes from #{state} to disabled on disable" do
        expect(empty_person).to transition_from(state).to(:disabled).on_event(:disable)
      end
    end
  
    %i(new enabled disabled rejected).each do |state|
      it "goes from #{state} to rejected on reject" do
        expect(empty_person).to transition_from(state).to(:rejected).on_event(:reject)
      end
    end
  end

  describe "When filter by admin tags" do
    let(:admin_user) { AdminUser.current_admin_user = create(:admin_user) }

    before :each do
      admin_user.tags.clear
      admin_user.save!
    end

    it "allow person creation only with admin tags" do
      person_tag1 = create(:person_tag)
      person_tag2 = create(:alt_person_tag)

      admin_user.tags << person_tag1
      admin_user.save!

      expect do
        person1 = Person.new
        person1.tags << person_tag1
        person1.save!
      end.to change { Person.count }.by(1)

      expect do
        person2 = Person.new
        person2.tags << person_tag2
        expect(person2).to_not be_valid
        expect(person2.errors[:person]).to eq(['Person tags not allowed'])
      end.to change { Person.count }.by(0)

      admin_user.tags << person_tag2
      admin_user.save!

      expect do
        person3 = Person.new
        person3.tags << person_tag1
        person3.save!
      end.to change { Person.count }.by(1)

      expect do
        person4 = Person.new
        person4.tags << person_tag2
        person4.save!
      end.to change { Person.count }.by(1)
    end

    it "allow person creation with tags if admin has no tags" do
      person_tag1 = create(:person_tag)
      person_tag2 = create(:alt_person_tag)

      expect do
        person1 = Person.new
        person1.tags << person_tag1
        person1.save!
      end.to change { Person.count }.by(1)

      expect do
        person2 = Person.new
        person2.tags << person_tag2
        person2.save!
      end.to change { Person.count }.by(1)
    end

    it "allow person creation without tags if admin has no tags" do
      expect do
        person = Person.new
        person.save!
      end.to change { Person.count }.by(1)
    end

    it "allow person creation without tags if admin has tags" do
      person_tag = create(:person_tag)

      admin_user.tags << person_tag
      admin_user.save!

      expect do
        person = Person.new
        person.save!
      end.to change { Person.count }.by(1)
    end

    it "allow change state with person tags if admin has tags" do
      person1, person2, person3, person4 = setup_for_admin_tags_spec

      admin_user.tags << person1.tags.first
      admin_user.save!

      %i{enable disable reject}.each do |action|
        person = Person.find(person1.id)
        person.send("#{action}!")

        person = Person.find(person2.id)
        person.send("#{action}!")

        expect { Person.find(person3.id) }.to raise_error(ActiveRecord::RecordNotFound)

        person = Person.find(person4.id)
        person.send("#{action}!")
      end

      admin_user.tags << person3.tags.first
      admin_user.save!

      %i{enable disable reject}.each do |action|
        person = Person.find(person3.id)
        person.send("#{action}!")
      end
    end

    it "Update a person with tags if admin has tags" do
      person1, person2, person3, person4 = setup_for_admin_tags_spec

      person = Person.find(person1.id)
      person.enabled = false
      person.save!

      person = Person.find(person2.id)
      person.enabled = false
      person.save!

      person = Person.find(person3.id)
      person.enabled = false
      person.save!

      person = Person.find(person4.id)
      person.enabled = false
      person.save!

      admin_user.tags << person1.tags.first
      admin_user.save!

      person = Person.find(person1.id)
      person.enabled = false
      person.save!

      person = Person.find(person2.id)
      person.enabled = false
      person.save!

      expect { Person.find(person3.id) }.to raise_error(ActiveRecord::RecordNotFound)

      person = Person.find(person4.id)
      person.enabled = false
      person.save!

      admin_user.tags << person3.tags.first
      admin_user.save!

      person = Person.find(person3.id)
      person.enabled = false
      person.save!
    end

    it "show person with active tags" do
      person1, person2, person3, person4 = setup_for_admin_tags_spec

      expect(Person.find(person1.id)).to_not be_nil
      expect(Person.find(person2.id)).to_not be_nil
      expect(Person.find(person3.id)).to_not be_nil
      expect(Person.find(person4.id)).to_not be_nil

      admin_user.tags << person1.tags.first
      admin_user.save!

      expect(Person.find(person1.id)).to_not be_nil
      expect(Person.find(person2.id)).to_not be_nil
      expect { Person.find(person3.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(Person.find(person4.id)).to_not be_nil

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      expect { Person.find(person1.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(Person.find(person2.id)).to_not be_nil
      expect(Person.find(person3.id)).to_not be_nil
      expect(Person.find(person4.id)).to_not be_nil

      admin_user.tags << person1.tags.first
      admin_user.save!

      expect(Person.find(person1.id)).to_not be_nil
      expect(Person.find(person2.id)).to_not be_nil
      expect(Person.find(person3.id)).to_not be_nil
      expect(Person.find(person4.id)).to_not be_nil
    end

    it "index person with active tags" do
      person1, person2, person3, person4 = setup_for_admin_tags_spec

      persons = Person.all
      expect(persons.count).to eq(4)
      expect(persons[0].id).to eq(person1.id)
      expect(persons[1].id).to eq(person2.id)
      expect(persons[2].id).to eq(person3.id)
      expect(persons[3].id).to eq(person4.id)

      admin_user.tags << person1.tags.first
      admin_user.save!

      persons = Person.all
      expect(persons.count).to eq(3)
      expect(persons[0].id).to eq(person1.id)
      expect(persons[1].id).to eq(person2.id)
      expect(persons[2].id).to eq(person4.id)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      persons = Person.all
      expect(persons.count).to eq(3)
      expect(persons[0].id).to eq(person2.id)
      expect(persons[1].id).to eq(person3.id)
      expect(persons[2].id).to eq(person4.id)

      admin_user.tags << person1.tags.first
      admin_user.save!

      persons = Person.all
      expect(persons.count).to eq(4)
      expect(persons[0].id).to eq(person1.id)
      expect(persons[1].id).to eq(person2.id)
      expect(persons[2].id).to eq(person3.id)
      expect(persons[3].id).to eq(person4.id)
    end

    def setup_for_admin_tags_spec
      person1 = create(:full_person_tagging).person
      person2 = create(:empty_person)
      person3 = create(:alt_full_person_tagging).person
      person4 = create(:empty_person)
      person4.tags << person1.tags.first
      person4.tags << person3.tags.first

      [person1, person2, person3, person4]
    end
  end
end
