require 'rails_helper'

RSpec.describe PersonProfile, type: :model do
  it 'person profile can support utf-8' do
    issue = create(:basic_issue)
    create(:utf8_full_risk_score_seed, issue: issue)
    issue.approve!

    expect {
      PersonProfile.generate_pdf(issue.person, true, true)
    }.not_to raise_error
  end
end
