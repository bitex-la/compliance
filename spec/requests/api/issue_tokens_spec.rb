require 'rails_helper'

describe IssueToken do
  it 'show all observations from issue' do
    seed = build(:full_natural_docket_seed, issue: build(:basic_issue))
    seed.observations << [build(:observation), build(:robot_observation)]
    issue = seed.issue
    issue.save!
    issue_token = IssueToken.where(issue: issue).first

    api_get("/issue_tokens/#{issue_token.token}")
    expect(api_response.included.first.relationships.observations.data.count).to eq(2)
  end
end
