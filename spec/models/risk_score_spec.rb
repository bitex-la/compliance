require 'rails_helper'

RSpec.describe RiskScore, type: :model do
  let(:person) { create(:empty_person) } 
  let(:invalid_risk_score) { described_class.new }
  let(:valid_risk_score) { 
    create(:risk_score, person: person) }

  it_behaves_like 'archived_fruit', :risk_scores, :full_risk_score
    
  it 'is not valid without a person' do
    expect(invalid_risk_score).to_not be_valid
  end

  it 'is valid with a person' do
    expect(valid_risk_score).to be_valid
  end
end
