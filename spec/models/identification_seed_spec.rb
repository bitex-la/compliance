require 'rails_helper'

RSpec.describe IdentificationSeed, type: :model do
  let(:invalid_seed) { described_class.new }
  let(:valid_seed)   { create(:identification_seed) }

  it 'is not valid without an issue' do
    expect(invalid_seed).to_not be_valid
  end

  it 'is valid with an issue' do
    expect(valid_seed).to be_valid
  end
end
