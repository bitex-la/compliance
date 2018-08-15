require 'rails_helper'

RSpec.describe AffinitySeed, type: :model do
  let(:invalid_seed) { described_class.new }
  let(:valid_seed)   { 
    create(:affinity_seed, 
      related_person: create(:empty_person),
      affinity_kind: AffinityKind.find_by_code('spouse')
  )}

  it 'is not valid without an issue' do
    expect(invalid_seed).to_not be_valid
  end

  it 'is valid with an issue' do
    expect(valid_seed).to be_valid
  end
end
