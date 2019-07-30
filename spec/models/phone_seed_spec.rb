require 'rails_helper'
require "helpers/shared_examples_for_models"

RSpec.describe PhoneSeed, type: :model do
  it { is_expected.to strip_attribute :number }
  it { is_expected.to strip_attribute :country }
  it { is_expected.to strip_attribute :note }

  it_behaves_like 'whitespaced_seed', described_class.new, {
    number: ' +5491125410470 ',
    phone_kind_code: :main,
    country: 'AR ',
    note:  'please do not call on Sundays ',
  }

  it 'can add observation to seed' do
    create(:human_world_check_reason)
    valid_seed = create(:full_phone_seed_with_issue)
    
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

  it 'can remove a seed and observations' do
    create(:human_world_check_reason)
    valid_seed = create(:full_phone_seed_with_issue)

    obs = valid_seed.observations.build()
    obs.observation_reason = ObservationReason.first
    obs.scope = :admin
    valid_seed.save!

    issue = valid_seed.issue
    expect(issue.observations.count).to eq(1)

    expect do
      valid_seed.destroy!
    end.to change{ issue.observations.count }.by(-1)
  end
end
