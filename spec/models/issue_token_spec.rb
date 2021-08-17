require 'rails_helper'

RSpec.describe IssueToken, type: :model do
  it 'creates new issue token when there are obsevations' do
    seed = build(:full_natural_docket_seed, issue: build(:basic_issue))
    seed.observations << build(:observation)
    issue = seed.issue

    expect { issue.save! }.to change { IssueToken.count }.by 1
    expect(issue.reload.observations.count).to eq(1)
  end
end
