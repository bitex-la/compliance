require 'rails_helper'

describe IssueToken do
  it 'creates new issue token when there are obsevations' do
    seed = build(:full_natural_docket_seed, issue: build(:basic_issue))
    seed.observations << build(:observation)
    issue = seed.issue

    expect { issue.save! }.to change { IssueToken.count }.by 1
    expect(issue.issue_token.observations.count).to eq(1)
    assert_logging(issue, :observe_issue, 1, false)
  end

  it 'invalidates issue token when observations are answered' do
    seed = build(:full_natural_docket_seed, issue: build(:basic_issue))
    seed.observations << build(:observation)
    issue = seed.issue
    issue.save!

    expect(issue.reload.issue_token.valid_token?).to be true
    expect(issue.issue_token.observations.count).to eq(1)

    issue.reload.observations.first.answer!

    expect(issue.reload.issue_token.valid_token?).to be false
    assert_logging(issue, :observe_issue, 1, false)
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

  it 'does not generate token when issue has valid token' do
    seed = build(:full_natural_docket_seed, issue: build(:basic_issue))
    seed.observations << build(:observation)
    issue = seed.issue

    expect { issue.save! }.to change { IssueToken.count }.by 1
    expect(issue.reload.issue_token).not_to be nil

    issue.observations << build(:observation)
    expect { issue.save! }.not_to change { IssueToken.count }
    expect(issue.reload.issue_token.observations.count).to eq(2)
    assert_logging(issue, :observe_issue, 1, false)
  end
end
