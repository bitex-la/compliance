require 'rails_helper'

RSpec.describe IssueTagging, type: :model do
  it_behaves_like 'person_scopable',
    create: -> (person_id) { 
      issue = with_untagged_admin{ create(:basic_issue, person_id: person_id) }
      create(:some_issue_tagging, issue_id: issue.id)
    }

  let(:issue) { create(:basic_issue) }
  let(:tag) { create(:issue_tag) }
  let(:person_tag) { create(:person_tag) }

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

  it 'validates by_person_tag scope' do
    expect do
      issue.tags << tag
    end.to change{ issue.tags.count }.by(1)

    expect(Issue.by_person_tag person_tag.id).to be_empty 

    expect do
      issue.person.tags << person_tag
    end.to change{ issue.person.tags.count }.by(1)
    
    expect(Issue.by_person_tag person_tag.id).to include issue
  end

  describe "When filter by admin tags" do
    let(:admin_user) { AdminUser.current_admin_user = create(:admin_user) }

    before :each do
      admin_user
    end

    it "Destroy a issue tagging with person tags if admin has tags" do
      issue_tag1, issue_tag2, issue_tag3, issue_tag4 = setup_for_admin_tags_spec
      person1 = issue_tag1.issue.person
      person3 = issue_tag3.issue.person

      admin_user.tags << person1.tags.first
      expect(IssueTagging.find(issue_tag1.id).destroy).to be_truthy
      expect(IssueTagging.find(issue_tag2.id).destroy).to be_truthy
      expect(IssueTagging.find(issue_tag4.id).destroy).to be_truthy
      assert_not_accessible(issue_tag3)

      admin_user.tags << person3.tags.first
      expect(IssueTagging.find(issue_tag3.id).destroy).to be_truthy
    end
  end
end
