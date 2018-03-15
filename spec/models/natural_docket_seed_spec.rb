require 'rails_helper'

RSpec.describe NaturalDocketSeed, type: :model do
  let(:invalid_seed) { described_class.new }
  let(:valid_seed)   { create(:natural_docket_seed, issue: create(:basic_issue)) }

  it 'is not valid without an issue' do
    expect(invalid_seed).to_not be_valid
  end

  it 'is valid with an issue' do
    expect(valid_seed).to be_valid
  end
end
