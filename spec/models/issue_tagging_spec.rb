require 'rails_helper'

RSpec.describe IssueTagging, type: :model do
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

    it "allow issue tagging creation only with person valid admin tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:alt_full_person_tagging).person

      issue1 = create(:basic_issue, person: person1)
      issue2 = create(:basic_issue, person: person2)

      tag = create(:issue_tag)
      alt_tag = create(:alt_issue_tag)

      admin_user.tags << person1.tags.first

      expect do
        issue1 = IssueTagging.new(issue: Issue.find(issue1.id), tag: tag)
        issue1.save!
      end.to change { IssueTagging.count }.by(1)

      expect { Issue.find(issue2.id) }.to raise_error(ActiveRecord::RecordNotFound)

      admin_user.tags << person2.tags.first

      expect do
        issue1 = IssueTagging.new(issue: Issue.find(issue1.id), tag: alt_tag)
        issue1.save!
      end.to change { IssueTagging.count }.by(1)

      expect do
        issue1 = IssueTagging.new(issue: Issue.find(issue2.id), tag: tag)
        issue1.save!
      end.to change { IssueTagging.count }.by(1)
    end

    it "allow issue tagging creation with person tags if admin has no tags" do
      person = create(:full_person_tagging).person
      issue = create(:basic_issue, person: person)
      tag = create(:issue_tag)

      expect do
        issue1 = IssueTagging.new(issue: Issue.find(issue.id), tag: tag)
        issue1.save!
      end.to change { IssueTagging.count }.by(1)
    end

    it "allow issue tagging creation without person tags if admin has no tags" do
      person = create(:empty_person)

      issue = create(:basic_issue, person: person)
      tag = create(:issue_tag)

      expect do
        issue1 = IssueTagging.new(issue: Issue.find(issue.id), tag: tag)
        issue1.save!
      end.to change { IssueTagging.count }.by(1)
    end

    it "allow issue tagging creation without person tags if admin has tags" do
      person = create(:full_person_tagging).person

      admin_user.tags << person.tags.first

      issue = create(:basic_issue, person: person)
      tag = create(:issue_tag)

      expect do
        issue1 = IssueTagging.new(issue: Issue.find(issue.id), tag: tag)
        issue1.save!
      end.to change { IssueTagging.count }.by(1)
    end

    it "Destroy a issue tagging with person tags if admin has tags" do
      issue_tag1, issue_tag2, issue_tag3, issue_tag4 = setup_for_admin_tags_spec
      person1 = issue_tag1.issue.person
      person3 = issue_tag3.issue.person

      admin_user.tags << person1.tags.first

      expect(IssueTagging.find(issue_tag1.id).destroy).to be_truthy
      expect(IssueTagging.find(issue_tag2.id).destroy).to be_truthy
      expect { IssueTagging.find(issue_tag3.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(IssueTagging.find(issue_tag4.id).destroy).to be_truthy

      admin_user.tags << person3.tags.first

      expect(IssueTagging.find(issue_tag3.id).destroy).to be_truthy
    end

    it "show issue tagging with admin user active tags" do
      issue_tag1, issue_tag2, issue_tag3, issue_tag4 = setup_for_admin_tags_spec
      person1 = issue_tag1.issue.person
      person3 = issue_tag3.issue.person

      expect(IssueTagging.find(issue_tag1.id)).to_not be_nil
      expect(IssueTagging.find(issue_tag2.id)).to_not be_nil
      expect(IssueTagging.find(issue_tag3.id)).to_not be_nil
      expect(IssueTagging.find(issue_tag4.id)).to_not be_nil

      admin_user.tags << person1.tags.first

      expect(IssueTagging.find(issue_tag1.id)).to_not be_nil
      expect(IssueTagging.find(issue_tag2.id)).to_not be_nil
      expect { IssueTagging.find(issue_tag3.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(IssueTagging.find(issue_tag4.id)).to_not be_nil

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first

      expect { IssueTagging.find(issue_tag1.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(IssueTagging.find(issue_tag2.id)).to_not be_nil
      expect(IssueTagging.find(issue_tag3.id)).to_not be_nil
      expect(IssueTagging.find(issue_tag4.id)).to_not be_nil

      admin_user.tags << person1.tags.first

      expect(IssueTagging.find(issue_tag1.id)).to_not be_nil
      expect(IssueTagging.find(issue_tag2.id)).to_not be_nil
      expect(IssueTagging.find(issue_tag3.id)).to_not be_nil
      expect(IssueTagging.find(issue_tag4.id)).to_not be_nil
    end

    it "index issue tagging with admin user active tags" do
      issue_tag1, issue_tag2, issue_tag3, issue_tag4 = setup_for_admin_tags_spec
      person1 = issue_tag1.issue.person
      person3 = issue_tag3.issue.person

      issues_taggings = IssueTagging.all
      expect(issues_taggings.count).to eq(4)
      expect(issues_taggings[0].id).to eq(issue_tag1.id)
      expect(issues_taggings[1].id).to eq(issue_tag2.id)
      expect(issues_taggings[2].id).to eq(issue_tag3.id)
      expect(issues_taggings[3].id).to eq(issue_tag4.id)

      admin_user.tags << person1.tags.first

      issues_taggings = IssueTagging.all
      expect(issues_taggings.count).to eq(3)
      expect(issues_taggings[0].id).to eq(issue_tag1.id)
      expect(issues_taggings[1].id).to eq(issue_tag2.id)
      expect(issues_taggings[2].id).to eq(issue_tag4.id)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first

      issues_taggings = IssueTagging.all
      expect(issues_taggings.count).to eq(3)
      expect(issues_taggings[0].id).to eq(issue_tag2.id)
      expect(issues_taggings[1].id).to eq(issue_tag3.id)
      expect(issues_taggings[2].id).to eq(issue_tag4.id)

      admin_user.tags << person1.tags.first

      issues_taggings = IssueTagging.all
      expect(issues_taggings.count).to eq(4)
      expect(issues_taggings[0].id).to eq(issue_tag1.id)
      expect(issues_taggings[1].id).to eq(issue_tag2.id)
      expect(issues_taggings[2].id).to eq(issue_tag3.id)
      expect(issues_taggings[3].id).to eq(issue_tag4.id)
    end

    def setup_for_admin_tags_spec
      person1 = create(:full_person_tagging).person
      person2 = create(:empty_person)
      person3 = create(:alt_full_person_tagging).person
      person4 = create(:empty_person)
      person4.tags << person1.tags.first
      person4.tags << person3.tags.first

      issue1 = create(:basic_issue, person: person1)
      issue2 = create(:basic_issue, person: person2)
      issue3 = create(:basic_issue, person: person3)
      issue4 = create(:basic_issue, person: person4)

      tag = create(:issue_tag)

      issue_tag1 = create(:full_issue_tagging, issue: issue1, tag: tag)
      issue_tag2 = create(:full_issue_tagging, issue: issue2, tag: tag)
      issue_tag3 = create(:full_issue_tagging, issue: issue3, tag: tag)
      issue_tag4 = create(:full_issue_tagging, issue: issue4, tag: tag)

      [issue_tag1, issue_tag2, issue_tag3, issue_tag4]
    end
  end
end
