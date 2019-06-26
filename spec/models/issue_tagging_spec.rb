require 'rails_helper'

RSpec.describe IssueTagging, type: :model do
  let(:issue) { create(:basic_issue) }
  let(:tag) { create(:issue_tag) }

  it 'validates non null fields' do
    invalid = IssueTagging.new
    expect(invalid).not_to be_valid
    expect(invalid.errors.keys).to match_array(%i[
      issue tag ])
  end

  it 'is valid with an issue, and tag' do
    expect(create(:full_issue_tagging)).to be_valid
  end

  it 'is invalid tag type' do
    issue_tag = build(:invalid_type_issue_tagging)
    expect(issue_tag).to_not be_valid
    expect(issue_tag.errors.messages[:tag]).to include("can't be blank and must be issue tag")
  end

  it 'validates that we cannot add the same tag twice' do
    expect do
      issue.tags << tag
    end.to change{ issue.tags.count }.by(1)

    expect(issue).to be_valid

    expect {issue.tags << tag }.to raise_error(ActiveRecord::RecordInvalid,
      "Validation failed: Tag can't contain duplicates in the same issue")
  end
end