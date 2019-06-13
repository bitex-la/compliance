require 'rails_helper'

describe Tag do
  it 'fetch tags' do
    one = create(:person_tag)
  
    api_get "/tags"

    expect(api_response.data.size).to eq 1

    json_response.should == {
      data: [ 
        type: 'tag',
        id: one.id.to_s,
        attributes: {
          name: one.name,
          tag_type: one.tag_type,
          created_at: one.created_at.to_i,
          updated_at: one.updated_at.to_i
        }
      ],
      meta: {
        total_items: 1,
        total_pages: 1
      }
    }
  end

  it 'creates a new tag' do
    attributes = attributes_for(:alt_person_tag)

    api_create "/tags", {
      type: 'tags',
      attributes: attributes
    }

    api_response.data.attributes.to_h.should >= {
      name: attributes[:name],
      tag_type: attributes[:tag_type].to_s
    }

    tag = Tag.first
    expect(tag.name).to eq attributes[:name]
    expect(tag.tag_type).to eq attributes[:tag_type].to_s
  end

  it 'updates a tag' do
    one = create(:person_tag)

    api_update "/tags/#{one.id}", {
      type: 'tags',
      id: one.id,
      attributes: {name: 'new-name'}
    }

    api_response.data.attributes.to_h.should >= {
      name: 'new-name',
      tag_type: one.tag_type.to_s
    }

    tag = Tag.first
    expect(tag.name).to eq 'new-name'
    expect(tag.tag_type).to eq one.tag_type.to_s
  end

  it 'destroy a tag' do
    one = create(:person_tag)

    api_destroy "/tags/#{one.id}"
    
    response.body.should be_blank

    api_get "/tags/#{one.id}", {}, 404
  end
end