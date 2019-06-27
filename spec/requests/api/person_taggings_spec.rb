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
end