require 'rails_helper'

RSpec.describe PersonTagging, type: :model do
  let(:person) { create(:empty_person) }
  let(:tag) { create(:person_tag) }

  it 'validates non null fields' do
    invalid = PersonTagging.new
    expect(invalid).not_to be_valid
    expect(invalid.errors.keys).to match_array(%i[
      person tag ])
  end

  it 'is valid with a person, and tag' do
    expect(create(:full_person_tagging)).to be_valid
  end

  it 'is invalid tag type' do
    person_tag = build(:invalid_type_person_tagging)
    expect(person_tag).to_not be_valid
    expect(person_tag.errors.messages[:tag]).to include("can't be blank and must be person tag")
  end

  it 'validates that we cannot add the same tag twice' do
    expect do
      person.tags << tag
    end.to change{ person.tags.count }.by(1)

    expect(person).to be_valid

    expect {person.tags << tag }.to raise_error(ActiveRecord::RecordInvalid,
      "Validation failed: Tag can't contain duplicates in the same person")
  end

  describe "When filter by admin tags" do
    let(:admin_user) { AdminUser.current_admin_user = create(:admin_user) }

    before :each do
      admin_user
    end

    it "allow person tagging creation only with person valid admin tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:alt_full_person_tagging).person

      tag = create(:person_tag, name: 'new-tag1')
      alt_tag = create(:person_tag, name: 'new-tag2')

      admin_user.tags << person1.tags.first

      expect do
        person_tagging = PersonTagging.new(person: Person.find(person1.id), tag: tag)
        person_tagging.save!
      end.to change { PersonTagging.count }.by(1)

      expect { Person.find(person2.id) }.to raise_error(ActiveRecord::RecordNotFound)

      admin_user.tags << person2.tags.first

      expect do
        person_tagging = PersonTagging.new(person: Person.find(person1.id), tag: alt_tag)
        person_tagging.save!
      end.to change { PersonTagging.count }.by(1)

      expect do
        person_tagging = PersonTagging.new(person: Person.find(person2.id), tag: tag)
        person_tagging.save!
      end.to change { PersonTagging.count }.by(1)
    end

    it "allow person tagging creation with person tags if admin has no tags" do
      person = create(:full_person_tagging).person
      tag = create(:person_tag, name: 'new-tag1')

      expect do
        person_tagging = PersonTagging.new(person: Person.find(person.id), tag: tag)
        person_tagging.save!
      end.to change { PersonTagging.count }.by(1)
    end

    it "allow person tagging creation without person tags if admin has no tags" do
      person = create(:empty_person)
      tag = create(:person_tag, name: 'new-tag1')

      expect do
        person_tagging = PersonTagging.new(person: Person.find(person.id), tag: tag)
        person_tagging.save!
      end.to change { PersonTagging.count }.by(1)
    end

    it "allow person tagging creation without person tags if admin has tags" do
      person = create(:full_person_tagging).person

      admin_user.tags << person.tags.first

      tag = create(:person_tag, name: 'new-tag1')

      expect do
        person_tagging = PersonTagging.new(person: Person.find(person.id), tag: tag)
        person_tagging.save!
      end.to change { PersonTagging.count }.by(1)
    end

    it "Destroy a person tagging with person tags if admin has tags" do
      person_tag1, person_tag2, person_tag3, person_tag4 = setup_for_admin_tags_spec
      person1 = person_tag1.person
      person3 = person_tag3.person

      admin_user.tags << person1.tags.first

      expect(PersonTagging.find(person_tag1.id).destroy).to be_truthy
      expect { PersonTagging.find(person_tag2.id).destroy }.to raise_error(ActiveRecord::RecordNotFound)
      expect { PersonTagging.find(person_tag3.id).destroy }.to raise_error(ActiveRecord::RecordNotFound)
      expect(PersonTagging.find(person_tag4.id).destroy).to be_truthy

      admin_user.tags << person3.tags.first

      expect(PersonTagging.find(person_tag3.id).destroy).to be_truthy
    end

    it "show person tagging with admin user active tags" do
      person_tag1, person_tag2, person_tag3, person_tag4 = setup_for_admin_tags_spec
      person1 = person_tag1.person
      person3 = person_tag3.person

      expect(PersonTagging.find(person_tag1.id)).to_not be_nil
      expect(PersonTagging.find(person_tag2.id)).to_not be_nil
      expect(PersonTagging.find(person_tag3.id)).to_not be_nil
      expect(PersonTagging.find(person_tag4.id)).to_not be_nil

      admin_user.tags << person1.tags.first

      expect(PersonTagging.find(person_tag1.id)).to_not be_nil
      expect { PersonTagging.find(person_tag2.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { PersonTagging.find(person_tag3.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(PersonTagging.find(person_tag4.id)).to_not be_nil

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first

      expect { PersonTagging.find(person_tag1.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { PersonTagging.find(person_tag2.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(PersonTagging.find(person_tag3.id)).to_not be_nil
      expect(PersonTagging.find(person_tag4.id)).to_not be_nil

      admin_user.tags << person1.tags.first

      expect(PersonTagging.find(person_tag1.id)).to_not be_nil
      expect { PersonTagging.find(person_tag2.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(PersonTagging.find(person_tag3.id)).to_not be_nil
      expect(PersonTagging.find(person_tag4.id)).to_not be_nil
    end

    it "index person tagging with admin user active tags" do
      person_tag1, person_tag2, person_tag3, person_tag4 = setup_for_admin_tags_spec
      person1 = person_tag1.person
      person3 = person_tag3.person
      person4 = person_tag4.person

      person_taggings = PersonTagging.all
      expect(person_taggings.count).to eq(8)
      expect(person_taggings[0].id).to eq(person1.person_taggings.first.id)
      expect(person_taggings[1].id).to eq(person3.person_taggings.first.id)
      expect(person_taggings[2].id).to eq(person4.person_taggings.first.id)
      expect(person_taggings[3].id).to eq(person4.person_taggings.second.id)
      expect(person_taggings[4].id).to eq(person_tag1.id)
      expect(person_taggings[5].id).to eq(person_tag2.id)
      expect(person_taggings[6].id).to eq(person_tag3.id)
      expect(person_taggings[7].id).to eq(person_tag4.id)

      admin_user.tags << person1.tags.first

      person_taggings = PersonTagging.all
      expect(person_taggings.count).to eq(5)
      expect(person_taggings[0].id).to eq(person1.person_taggings.first.id)
      expect(person_taggings[1].id).to eq(person4.person_taggings.first.id)
      expect(person_taggings[2].id).to eq(person4.person_taggings.second.id)
      expect(person_taggings[3].id).to eq(person_tag1.id)
      expect(person_taggings[4].id).to eq(person_tag4.id)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first

      person_taggings = PersonTagging.all
      expect(person_taggings.count).to eq(5)
      expect(person_taggings[0].id).to eq(person3.person_taggings.first.id)
      expect(person_taggings[1].id).to eq(person4.person_taggings.first.id)
      expect(person_taggings[2].id).to eq(person4.person_taggings.second.id)
      expect(person_taggings[3].id).to eq(person_tag3.id)
      expect(person_taggings[4].id).to eq(person_tag4.id)

      admin_user.tags << person1.tags.first

      person_taggings = PersonTagging.all
      expect(person_taggings.count).to eq(7)
      expect(person_taggings[0].id).to eq(person1.person_taggings.first.id)
      expect(person_taggings[1].id).to eq(person3.person_taggings.first.id)
      expect(person_taggings[2].id).to eq(person4.person_taggings.first.id)
      expect(person_taggings[3].id).to eq(person4.person_taggings.second.id)
      expect(person_taggings[4].id).to eq(person_tag1.id)
      expect(person_taggings[5].id).to eq(person_tag3.id)
      expect(person_taggings[6].id).to eq(person_tag4.id)
    end

    def setup_for_admin_tags_spec
      person1 = create(:full_person_tagging).person
      person2 = create(:empty_person)
      person3 = create(:alt_full_person_tagging).person
      person4 = create(:empty_person)
      person4.tags << person1.tags.first
      person4.tags << person3.tags.first

      tag = create(:person_tag, name: 'new-tag1')

      person_tag1 = create(:full_person_tagging, person: person1, tag: tag)
      person_tag2 = create(:full_person_tagging, person: person2, tag: tag)
      person_tag3 = create(:full_person_tagging, person: person3, tag: tag)
      person_tag4 = create(:full_person_tagging, person: person4, tag: tag)

      [person_tag1, person_tag2, person_tag3, person_tag4]
    end
  end
end
