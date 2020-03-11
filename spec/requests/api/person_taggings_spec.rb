require 'rails_helper'

describe PersonTagging do
  it 'fetch person taggings' do
    one = create(:full_person_tagging)
  
    api_get "/person_taggings"

    expect(api_response.data.size).to eq 1

    json_response.should == {
      data: [ 
        type: 'person_tagging',
        id: one.id.to_s,
        attributes: {
          created_at: one.created_at.as_json,
          updated_at: one.updated_at.as_json
        },
        relationships: {
          person: {
            data: {
              id: one.person.id.to_s,
              type: "people"
            }
          },
          tag: {
            data: {
              id: one.tag.id.to_s,
              type: "tags"
            }
          }
        }
      ],
      meta: {
        total_items: 1,
        total_pages: 1
      }
    }
  end

  it 'creates a new person_tagging' do  
    person = create(:empty_person)
    tag = create(:person_tag)

    api_create "/person_taggings", {
      type: 'person_taggings',
      relationships: {
        person: {data: {id: person.id, type: 'people'}},
        tag: {data: {id: tag.id, type: 'tags'}}
      }
    }

    person_tagging = PersonTagging.first

    json_response.should >= {
      data: {
        id: "1",
        type: "person_tagging",
        attributes: {
          created_at: person_tagging.created_at.as_json,
          updated_at: person_tagging.updated_at.as_json
        },
        relationships: {
          person: {
            data: {
              id: person.id.to_s,
              type: "people"
            }
          },
          tag: {
            data: {
              id: tag.id.to_s,
              type: "tags"
            }
          }
        }
      }
    }

    expect(person_tagging.person).to eq person
    expect(person_tagging.tag).to eq tag
  end

  it 'destroy a person_tagging' do
    one = create(:full_person_tagging)

    api_destroy "/person_taggings/#{one.id}"
    
    response.body.should be_blank

    api_get "/person_taggings/#{one.id}", {}, 404
  end

  describe "When filter by admin tags" do
    let(:admin_user) { create(:admin_user) }

    before :each do
      admin_user.tags.clear
      admin_user.save!
    end

    it "allow person tagging creation only with person valid admin tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:alt_full_person_tagging).person

      tag = create(:person_tag, name: 'new-tag1')
      alt_tag = create(:person_tag, name: 'new-tag2')

      admin_user.tags << person1.tags.first
      admin_user.save!

      expect do
        api_create "/person_taggings",
          type: 'person_taggings',
          relationships: {
            person: { data: { id: person1.id, type: 'people' } },
            tag: { data: { id: tag.id, type: 'tags' } }
          }
      end.to change { PersonTagging.count }.by(1)

      person_tag = PersonTagging.last
      expect(api_response.data.id).to eq(person_tag.id.to_s)

      expect do
        api_create "/person_taggings", {
          type: 'person_taggings',
          relationships: {
            person: { data: { id: person2.id, type: 'people' } },
            tag: { data: { id: tag.id, type: 'tags' } }
          } }, 404
      end.to change { PersonTagging.count }.by(0)

      expect(person_tag).to eq(PersonTagging.last)

      admin_user.tags << person2.tags.first
      admin_user.save!

      expect do
        api_create "/person_taggings",
          type: 'person_taggings',
          relationships: {
            person: { data: { id: person1.id, type: 'people' } },
            tag: { data: { id: alt_tag.id, type: 'tags' } }
          }
      end.to change { PersonTagging.count }.by(1)

      person_tag = PersonTagging.last
      expect(api_response.data.id).to eq(person_tag.id.to_s)

      expect do
        api_create "/person_taggings",
          type: 'person_taggings',
          relationships: {
            person: { data: { id: person2.id, type: 'people' } },
            tag: { data: { id: tag.id, type: 'tags' } }
          }
      end.to change { PersonTagging.count }.by(1)

      person_tag = PersonTagging.last
      expect(api_response.data.id).to eq(person_tag.id.to_s)
    end

    it "allow person tagging creation with person tags if admin has no tags" do
      person = create(:full_person_tagging).person
      tag = create(:person_tag, name: 'new-tag1')

      expect do
        api_create "/person_taggings",
          type: 'person_taggings',
          relationships: {
            person: { data: { id: person.id, type: 'people' } },
            tag: { data: { id: tag.id, type: 'tags' } }
          }
      end.to change { PersonTagging.count }.by(1)
    end

    it "allow person tagging creation without person tags if admin has no tags" do
      person = create(:empty_person)
      tag = create(:person_tag, name: 'new-tag1')

      expect do
        api_create "/person_taggings",
          type: 'person_taggings',
          relationships: {
            person: { data: { id: person.id, type: 'people' } },
            tag: { data: { id: tag.id, type: 'tags' } }
          }
      end.to change { PersonTagging.count }.by(1)
    end

    it "allow person tagging creation without person tags if admin has tags" do
      person = create(:full_person_tagging).person

      admin_user.tags << person.tags.first
      admin_user.save!

      tag = create(:person_tag, name: 'new-tag1')

      expect do
        api_create "/person_taggings",
          type: 'person_taggings',
          relationships: {
            person: { data: { id: person.id, type: 'people' } },
            tag: { data: { id: tag.id, type: 'tags' } }
          }
      end.to change { PersonTagging.count }.by(1)
    end

    it "Destroy a person tagging with person tags if admin has tags" do
      person_tag1, person_tag2, person_tag3, person_tag4 = setup_for_admin_tags_spec
      person1 = person_tag1.person
      person3 = person_tag3.person

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_destroy "/person_taggings/#{person_tag1.id}"
      response.body.should be_blank
      api_get "/person_taggings/#{person_tag1.id}", {}, 404

      api_destroy "/person_taggings/#{person_tag2.id}", 404

      api_destroy "/person_taggings/#{person_tag3.id}", 404

      api_destroy "/person_taggings/#{person_tag4.id}"
      response.body.should be_blank
      api_get "/person_taggings/#{person_tag4.id}", {}, 404

      admin_user.tags << person3.tags.first
      admin_user.save!

      api_destroy "/person_taggings/#{person_tag3.id}"
      response.body.should be_blank
      api_get "/person_taggings/#{person_tag3.id}", {}, 404
    end

    it "show person tagging with admin user active tags" do
      person_tag1, person_tag2, person_tag3, person_tag4 = setup_for_admin_tags_spec
      person1 = person_tag1.person
      person3 = person_tag3.person

      api_get("/person_taggings/#{person_tag1.id}")
      api_get("/person_taggings/#{person_tag2.id}")
      api_get("/person_taggings/#{person_tag3.id}")
      api_get("/person_taggings/#{person_tag4.id}")

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/person_taggings/#{person_tag1.id}")
      api_get("/person_taggings/#{person_tag2.id}", {}, 404)
      api_get("/person_taggings/#{person_tag3.id}", {}, 404)
      api_get("/person_taggings/#{person_tag4.id}")

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      api_get("/person_taggings/#{person_tag1.id}", {}, 404)
      api_get("/person_taggings/#{person_tag2.id}", {}, 404)
      api_get("/person_taggings/#{person_tag3.id}")
      api_get("/person_taggings/#{person_tag4.id}")

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/person_taggings/#{person_tag1.id}")
      api_get("/person_taggings/#{person_tag2.id}", {}, 404)
      api_get("/person_taggings/#{person_tag3.id}")
      api_get("/person_taggings/#{person_tag4.id}")
    end

    it "index person tagging with admin user active tags" do
      person_tag1, person_tag2, person_tag3, person_tag4 = setup_for_admin_tags_spec
      person1 = person_tag1.person
      person3 = person_tag3.person
      person4 = person_tag4.person

      api_get("/person_taggings/")
      expect(api_response.meta.total_items).to eq(8)
      expect(api_response.data[0].id).to eq(person_tag4.id.to_s)
      expect(api_response.data[1].id).to eq(person_tag3.id.to_s)
      expect(api_response.data[2].id).to eq(person_tag2.id.to_s)
      expect(api_response.data[3].id).to eq(person_tag1.id.to_s)
      expect(api_response.data[4].id).to eq(person4.person_taggings.second.id.to_s)
      expect(api_response.data[5].id).to eq(person4.person_taggings.first.id.to_s)
      expect(api_response.data[6].id).to eq(person3.person_taggings.first.id.to_s)
      expect(api_response.data[7].id).to eq(person1.person_taggings.first.id.to_s)

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/person_taggings/")
      expect(api_response.meta.total_items).to eq(5)
      expect(api_response.data[0].id).to eq(person_tag4.id.to_s)
      expect(api_response.data[1].id).to eq(person_tag1.id.to_s)
      expect(api_response.data[2].id).to eq(person4.person_taggings.second.id.to_s)
      expect(api_response.data[3].id).to eq(person4.person_taggings.first.id.to_s)
      expect(api_response.data[4].id).to eq(person1.person_taggings.first.id.to_s)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      api_get("/person_taggings/")
      expect(api_response.meta.total_items).to eq(5)
      expect(api_response.data[0].id).to eq(person_tag4.id.to_s)
      expect(api_response.data[1].id).to eq(person_tag3.id.to_s)
      expect(api_response.data[2].id).to eq(person4.person_taggings.second.id.to_s)
      expect(api_response.data[3].id).to eq(person4.person_taggings.first.id.to_s)
      expect(api_response.data[4].id).to eq(person3.person_taggings.first.id.to_s)

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/person_taggings/")
      expect(api_response.meta.total_items).to eq(7)
      expect(api_response.data[0].id).to eq(person_tag4.id.to_s)
      expect(api_response.data[1].id).to eq(person_tag3.id.to_s)
      expect(api_response.data[2].id).to eq(person_tag1.id.to_s)
      expect(api_response.data[3].id).to eq(person4.person_taggings.second.id.to_s)
      expect(api_response.data[4].id).to eq(person4.person_taggings.first.id.to_s)
      expect(api_response.data[5].id).to eq(person3.person_taggings.first.id.to_s)
      expect(api_response.data[6].id).to eq(person1.person_taggings.first.id.to_s)
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
