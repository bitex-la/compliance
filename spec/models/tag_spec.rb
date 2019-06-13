require 'rails_helper'

RSpec.describe Tag, type: :model do
  it 'is invalid if empty' do
    expect(Tag.new).to_not be_valid
  end

  it 'is invalid if name is too long' do
    tag = build(:long_name_tag)
    expect(tag).to_not be_valid
    expect(tag.errors.messages).to include :name
  end

  it 'is invalid without type' do
    tag = build(:empty_tag)
    tag.name = 'valid-name'
    expect(tag).to_not be_valid
    expect(tag.errors.messages).to include :tag_type
  end

  it 'is invalid when is duplicate' do
    tag1 = create(:person_tag)
    expect(tag1).to be_valid
    
    tag2 = build(:person_tag)
    expect(tag2).to_not be_valid
    expect(tag2.errors.messages).to include :name
  end

  it 'is invalid if name contains invalid chars' do
    tag = build(:invalid_name_tag)
    expect(tag).to_not be_valid
    expect(tag.errors.messages).to include :name
    expect(tag.errors.messages[:name]).to include('only support letters, numbers and hyphen')
  end

  it 'creates a person tag' do
    tag = create(:person_tag)
    expect(tag).to be_valid
  end

  it 'creates an issue tag' do
    tag = create(:issue_tag)
    expect(tag).to be_valid
  end

  it 'is in person scope' do
    tag = create(:person_tag)
    expect(Tag.person).to include tag
    expect(Tag.issue).to_not include tag
  end

  it 'is in issue scope' do
    tag = create(:issue_tag)
    expect(Tag.person).to_not include tag
    expect(Tag.issue).to include tag
  end
end