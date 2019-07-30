require 'rails_helper'
require 'helpers/shared_examples_for_models'

RSpec.describe IdentificationSeed, type: :model do
  let(:invalid_seed) { described_class.new }
  let(:valid_seed)   { 
    create(:identification_seed, 
      identification_kind: IdentificationKind.find_by_code('national_id'),
      issuer: 'CO'
  )}

  %i(number issuer public_registry_authority 
  public_registry_book public_registry_extra_data).each do |attr|
    it { is_expected.to strip_attribute attr }
  end

  it_behaves_like 'whitespaced_seed', described_class.new, {
    number: '20955794280  ',
    issuer: 'AR ',
    identification_kind_code: :tax_id,
    public_registry_authority: ' AFIP ' ,
    public_registry_book: ' 23456 ',
    public_registry_extra_data: ' 344343'
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

  it 'can remove a seed and observations' do
    create(:human_world_check_reason)
    
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
