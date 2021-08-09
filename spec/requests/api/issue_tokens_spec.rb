require 'rails_helper'

describe IssueToken do
  describe 'updates observations issues' do
    it 'add reply for a natural docket seeds observations' do
      seed = build(:full_natural_docket_seed, issue: build(:basic_issue))
      seed.observations << build(:observation)
      issue = seed.issue

      expect { issue.save! }.to change { IssueToken.count }.by 1
      expect(issue.reload.observations.count).to eq(1)
    end
  end
end
