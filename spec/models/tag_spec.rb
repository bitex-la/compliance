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
    tag = build(:empty_tag, name: 'valid-name')
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

  it 'can not destroy if person_tagging exists' do
    tag = create(:person_tag)
    person_tagging = create(:full_person_tagging, tag: tag)
    expect(tag.destroy).to eq(false)
  end

  it 'can not destroy if issue_tagging exists' do
    tag = create(:issue_tag)
    issue_tagging = create(:full_issue_tagging, tag: tag)
    expect(tag.destroy).to eq(false)
  end

  it 'can destroy if relation not exists' do
    tag = create(:person_tag)
    expect(tag.destroy).to eq(tag)
    expect(Tag.find_by_id(tag.id)).to be nil
  end
end