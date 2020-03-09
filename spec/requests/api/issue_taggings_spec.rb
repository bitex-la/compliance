require 'rails_helper'

describe IssueTagging do
  it 'fetch issue taggings' do
    one = create(:full_issue_tagging)
  
    api_get "/issue_taggings"

    expect(api_response.data.size).to eq 1

    json_response.should == {
      data: [ 
        type: 'issue_tagging',
        id: one.id.to_s,
        attributes: {
          created_at: one.created_at.as_json,
          updated_at: one.updated_at.as_json
        },
        relationships: {
          issue: {
            data: {
              id: one.issue.id.to_s,
              type: "issues"
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

  it 'creates a new issue_tagging' do  
    issue = create(:basic_issue)
    tag = create(:issue_tag)

    api_create "/issue_taggings", {
      type: 'issue_taggings',
      relationships: {
        issue: {data: {id: issue.id, type: 'issues'}},
        tag: {data: {id: tag.id, type: 'tags'}}
      }
    }

    issue_tagging = IssueTagging.first

    json_response.should >= {
      data: {
        id: "1",
        type: "issue_tagging",
        attributes: {
          created_at: issue_tagging.created_at.as_json,
          updated_at: issue_tagging.updated_at.as_json
        },
        relationships: {
          issue: {
            data: {
              id: issue.id.to_s,
              type: "issues"
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

    expect(issue_tagging.issue).to eq issue
    expect(issue_tagging.tag).to eq tag
  end

  it 'destroy an issue_tagging' do
    one = create(:full_issue_tagging)

    api_destroy "/issue_taggings/#{one.id}"
    
    response.body.should be_blank

    api_get "/issue_taggings/#{one.id}", {}, 404
  end

  describe "When filter by admin tags" do
    let(:admin_user) { create(:admin_user) }

    before :each do
      admin_user.tags.clear
      admin_user.save!
    end

    it "allow issue tagging creation only with person valid admin tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:alt_full_person_tagging).person

      issue1 = create(:basic_issue, person: person1)
      issue2 = create(:basic_issue, person: person2)

      tag = create(:issue_tag)
      alt_tag = create(:alt_issue_tag)

      admin_user.tags << person1.tags.first
      admin_user.save!

      expect do
        api_create "/issue_taggings",
          type: 'issue_taggings',
          relationships: {
            issue: { data: { id: issue1.id, type: 'issues' } },
            tag: { data: { id: tag.id, type: 'tags' } }
          }
      end.to change { IssueTagging.count }.by(1)

      issue_tag = IssueTagging.last
      expect(api_response.data.id).to eq(issue_tag.id.to_s)

      expect do
        api_create "/issue_taggings", {
          type: 'issue_taggings',
          relationships: {
            issue: { data: { id: issue2.id, type: 'issues' } },
            tag: { data: { id: tag.id, type: 'tags' } }
          } }, 404
      end.to change { IssueTagging.count }.by(0)

      expect(issue_tag).to eq(IssueTagging.last)

      admin_user.tags << person2.tags.first
      admin_user.save!

      expect do
        api_create "/issue_taggings",
          type: 'issue_taggings',
          relationships: {
            issue: { data: { id: issue1.id, type: 'issues' } },
            tag: { data: { id: alt_tag.id, type: 'tags' } }
          }
      end.to change { IssueTagging.count }.by(1)

      issue_tag = IssueTagging.last
      expect(api_response.data.id).to eq(issue_tag.id.to_s)

      expect do
        api_create "/issue_taggings",
          type: 'issue_taggings',
          relationships: {
            issue: { data: { id: issue2.id, type: 'issues' } },
            tag: { data: { id: tag.id, type: 'tags' } }
          }
      end.to change { IssueTagging.count }.by(1)

      issue_tag = IssueTagging.last
      expect(api_response.data.id).to eq(issue_tag.id.to_s)
    end

    it "allow issue tagging creation with person tags if admin has no tags" do
      person = create(:full_person_tagging).person
      issue1 = create(:basic_issue, person: person)
      tag = create(:issue_tag)

      expect do
        api_create "/issue_taggings",
          type: 'issue_taggings',
          relationships: {
            issue: { data: { id: issue1.id, type: 'issues' } },
            tag: { data: { id: tag.id, type: 'tags' } }
          }
      end.to change { IssueTagging.count }.by(1)
    end

    it "allow issue tagging creation without person tags if admin has no tags" do
      person = create(:empty_person)

      issue1 = create(:basic_issue, person: person)
      tag = create(:issue_tag)

      expect do
        api_create "/issue_taggings",
          type: 'issue_taggings',
          relationships: {
            issue: { data: { id: issue1.id, type: 'issues' } },
            tag: { data: { id: tag.id, type: 'tags' } }
          }
      end.to change { IssueTagging.count }.by(1)
    end

    it "allow issue tagging creation without person tags if admin has tags" do
      person = create(:full_person_tagging).person

      admin_user.tags << person.tags.first
      admin_user.save!

      issue1 = create(:basic_issue, person: person)
      tag = create(:issue_tag)

      expect do
        api_create "/issue_taggings",
          type: 'issue_taggings',
          relationships: {
            issue: { data: { id: issue1.id, type: 'issues' } },
            tag: { data: { id: tag.id, type: 'tags' } }
          }
      end.to change { IssueTagging.count }.by(1)
    end

    it "show issue tagging with admin user active tags" do
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

      api_get("/issue_taggings/#{issue_tag1.id}")
      api_get("/issue_taggings/#{issue_tag2.id}")
      api_get("/issue_taggings/#{issue_tag3.id}")
      api_get("/issue_taggings/#{issue_tag4.id}")

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/issue_taggings/#{issue_tag1.id}")
      api_get("/issue_taggings/#{issue_tag2.id}")
      api_get("/issue_taggings/#{issue_tag3.id}", {}, 404)
      api_get("/issue_taggings/#{issue_tag4.id}")

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      api_get("/issue_taggings/#{issue_tag1.id}", {}, 404)
      api_get("/issue_taggings/#{issue_tag2.id}")
      api_get("/issue_taggings/#{issue_tag3.id}")
      api_get("/issue_taggings/#{issue_tag4.id}")

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/issue_taggings/#{issue_tag1.id}")
      api_get("/issue_taggings/#{issue_tag2.id}")
      api_get("/issue_taggings/#{issue_tag3.id}")
      api_get("/issue_taggings/#{issue_tag4.id}")
    end

    it "index issue tagging with admin user active tags" do
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

      api_get("/issue_taggings/")
      expect(api_response.meta.total_items).to eq(4)
      expect(api_response.data[0].id).to eq(issue_tag4.id.to_s)
      expect(api_response.data[1].id).to eq(issue_tag3.id.to_s)
      expect(api_response.data[2].id).to eq(issue_tag2.id.to_s)
      expect(api_response.data[3].id).to eq(issue_tag1.id.to_s)

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/issue_taggings/")
      expect(api_response.meta.total_items).to eq(3)
      expect(api_response.data[0].id).to eq(issue_tag4.id.to_s)
      expect(api_response.data[1].id).to eq(issue_tag2.id.to_s)
      expect(api_response.data[2].id).to eq(issue_tag1.id.to_s)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      api_get("/issue_taggings/")
      expect(api_response.meta.total_items).to eq(3)
      expect(api_response.data[0].id).to eq(issue_tag4.id.to_s)
      expect(api_response.data[1].id).to eq(issue_tag3.id.to_s)
      expect(api_response.data[2].id).to eq(issue_tag2.id.to_s)

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/issue_taggings/")
      expect(api_response.meta.total_items).to eq(4)
      expect(api_response.data[0].id).to eq(issue_tag4.id.to_s)
      expect(api_response.data[1].id).to eq(issue_tag3.id.to_s)
      expect(api_response.data[2].id).to eq(issue_tag2.id.to_s)
      expect(api_response.data[3].id).to eq(issue_tag1.id.to_s)
    end
  end
end
