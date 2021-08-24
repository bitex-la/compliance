require 'rails_helper'

RSpec.describe IssueToken, type: :model do
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
end
