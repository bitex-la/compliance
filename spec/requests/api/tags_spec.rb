require 'rails_helper'

describe Tag do
  it 'fetch tags' do
    one = create(:person_tag)
  
    api_get "/tags"

    expect(api_response.data.size).to eq 1

    json_response.should == {
      data: [ 
        type: 'tags',
        id: one.id.to_s,
        attributes: {
          name: one.name,
          tag_type: one.tag_type,
          created_at: one.created_at.as_json,
          updated_at: one.updated_at.as_json
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

  it 'restricted user is not allowed' do
    restricted_admin = create(:compliance_admin_user)
    AdminUser.current_admin_user = restricted_admin
    
    one = create(:person_tag)

    api_get "/tags", {}, 403
    api_destroy "/tags/#{one.id}", 403
    api_create "/tags", {
      type: 'tags',
      attributes: attributes_for(:alt_person_tag)
    }, 403
    api_update "/tags/#{one.id}", {
      type: 'tags',
      id: one.id,
      attributes: {name: 'new-name'}
    }, 403
  end

  describe 'when using filters' do
    it 'filters by name' do
      one = create(:person_tag)
      
      api_get "/tags/?filter[name_eq]=this-is-a-person-tag-1"
      api_response.data.map{|i| i.id.to_i}.to_set.should ==
        [one.id].to_set
        
      api_get "/tags/?filter[name_eq]=not-exists"
      expect(api_response.data).to be_empty
    end

    it 'filters by tag type' do
      person_tag = create(:person_tag)
      issue_tag = create(:issue_tag)
      
      api_get "/tags/?filter[tag_type_eq]=person"
      api_response.data.map{|i| i.id.to_i}.to_set.should ==
        [person_tag.id].to_set
      
      api_get "/tags/?filter[tag_type_eq]=issue"
      api_response.data.map{|i| i.id.to_i}.to_set.should ==
        [issue_tag.id].to_set
    end
  end
end
