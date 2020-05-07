require 'rails_helper'

RSpec.describe AdminUserTagging, type: :model do
  let(:admin_user) { create(:admin_user) }
  let(:tag) { create(:person_tag) }

  it 'validates non null fields' do
    invalid = AdminUserTagging.new
    expect(invalid).not_to be_valid
    expect(invalid.errors.keys).to eq %i[admin_user tag]
      admin_user tag ])
  end

  it 'is valid with an admin user and tag' do
    expect(create(:full_admin_user_tagging)).to be_valid
  end

  it 'is invalid tag type' do
    admin_user_tag = build(:invalid_type_admin_user_tagging)
    expect(admin_user_tag).to_not be_valid
    expect(admin_user_tag.errors.messages[:tag]).to include("can't be blank and must be person tag")
  end

  it 'validates that we cannot add the same tag twice' do
    expect do
      admin_user.tags << tag
    end.to change { admin_user.tags.count }.by(1)

    expect(admin_user).to be_valid

    expect { admin_user.tags << tag }.to raise_error(ActiveRecord::RecordInvalid,
      "Validation failed: Tag can't contain duplicates in the same admin_user")
  end
end
