require 'rails_helper'

describe AdminUserTagging do
  it 'fetch admin_user taggings' do
    one = create(:full_admin_user_tagging)

    api_get "/admin_user_taggings"

    expect(api_response.data.size).to eq 1

    json_response.should == {
      data: [
        type: 'admin_user_tagging',
        id: one.id.to_s,
        attributes: {
          created_at: one.created_at.as_json,
          updated_at: one.updated_at.as_json
        },
        relationships: {
          admin_user: {
            data: {
              id: one.admin_user.id.to_s,
              type: 'admin_users'
            }
          },
          tag: {
            data: {
              id: one.tag.id.to_s,
              type: 'tags'
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

  it 'creates a new admin_user_tagging' do  
    admin = create(:admin_user)
    tag = create(:person_tag)

    api_create "/admin_user_taggings", {
      type: 'admin_user_taggings',
      relationships: {
        admin_user: {data: {id: admin.id, type: 'admin_users'}},
        tag: {data: {id: tag.id, type: 'tags'}}
      }
    }

    admin_user_tagging = AdminUserTagging.first

    expect(json_response).to eq(
      data: {
        id: '1',
        type: 'admin_user_tagging',
        attributes: {
          created_at: admin_user_tagging.created_at.as_json,
          updated_at: admin_user_tagging.updated_at.as_json
        },
        relationships: {
          admin_user: {
            data: {
              id: admin.id.to_s,
              type: 'admin_users'
            }
          },
          tag: {
            data: {
              id: tag.id.to_s,
              type: 'tags'
            }
          }
        }
      }
    )

    expect(admin_user_tagging.admin_user).to eq admin
    expect(admin_user_tagging.tag).to eq tag
  end

  it 'destroy an admin_user_tagging' do
    one = create(:full_admin_user_tagging)

    api_destroy "/admin_user_taggings/#{one.id}"

    response.body.should be_blank

    api_get "/admin_user_taggings/#{one.id}", {}, 404
  end
end
