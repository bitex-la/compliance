require 'rails_helper'

RSpec.describe RiskScoreSeed, type: :model do
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

  it 'can add observation to seed' do
    create(:human_world_check_reason)
    
    expect do
      obs = valid_seed.observations.build()
      obs.observation_reason = ObservationReason.first
      obs.scope = :admin
      valid_seed.save!  
    end.to change{ valid_seed.observations.count }.by(1)

    first = valid_seed.observations.first 
    expect(first.observation_reason).to eq(ObservationReason.first)
    expect(first.scope).to eq("admin")
    expect(first.observable).to eq(valid_seed)
  end
end
