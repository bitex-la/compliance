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
end
