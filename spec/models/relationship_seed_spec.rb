require 'rails_helper'

RSpec.describe RelationshipSeed, type: :model do
  let(:invalid_seed) { described_class.new }
  let(:valid_seed)   { 
    create(:relationship_seed, 
      related_person: create(:empty_person),
      kind: RelationshipKind.find(10).id
  )}

  it 'is not valid without an issue' do
    expect(invalid_seed).to_not be_valid
  end

  it 'is valid with an issue' do
    expect(valid_seed).to be_valid
  end
end
