require 'rails_helper'

describe IssueToken do
  it 'creates new issue token when there are obsevations' do
    seed = build(:full_natural_docket_seed, issue: build(:basic_issue))
    seed.observations << build(:observation)
    issue = seed.issue

    expect { issue.save! }.to change { IssueToken.count }.by 1
    expect(issue.issue_token.observations.count).to eq(1)
  end

  it 'only shows issue token observations when are not answered' do
    seed = build(:full_natural_docket_seed, issue: build(:basic_issue))
    seed.observations << build(:observation)
    issue = seed.issue
    issue.save!
    issue.reload.observations.first.answer!

    expect(issue.issue_token.observations.count).to eq(0)
  end

  it 'creates new issue token for client observations on observed issue' do
    seed = build(:full_natural_docket_seed, issue: build(:basic_issue))
    seed.observations << build(:robot_observation)
    issue = seed.issue

    expect { issue.save! }.to change { IssueToken.count }.by 0
    expect(issue.reload.issue_token).to be nil

    issue.observations << build(:observation)
    expect { issue.save! }.to change { IssueToken.count }.by 1
    expect(issue.reload.issue_token.observations.count).to eq(1)
  end
end
