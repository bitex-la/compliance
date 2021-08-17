require 'rails_helper'

describe IssueToken do
  let(:issue) { build(:basic_issue) }
  let(:seed) { build(:full_natural_docket_seed, issue: issue) }

  before(:each) do
    seed.observations << [build(:observation), build(:robot_observation)]
    issue = seed.issue
    issue.save!
  end

  it 'show all observations from issue' do
    issue_token = IssueToken.where(issue: issue).first

    api_get("/issue_tokens/#{issue_token.token}")
    expect(api_response.included.first.relationships.observations.data.count).to eq(2)
  end

  it 'responds with 410 error when token is invalid' do
    issue_token = IssueToken.where(issue: issue).first
    Timecop.travel 31.days.from_now

    api_get("/issue_tokens/#{issue_token.token}", {}, 410)
  end
end
