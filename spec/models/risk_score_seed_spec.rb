require 'rails_helper'

describe RiskScoreSeed do
  let(:invalid_seed) { described_class.new }
  let(:valid_seed) {
    create(:risk_score_seed,
      issue: create(:basic_issue)
    )
  }
  it 'is not valid without an issue' do
    expect(invalid_seed).to_not be_valid
  end

  it 'is valid with an issue' do
    expect(valid_seed).to be_valid
  end

  it_behaves_like 'observable'

  it_behaves_like 'seed_model',
    :risk_scores,
    :full_risk_score,
    :alt_full_risk_score
end
