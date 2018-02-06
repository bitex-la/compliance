require 'rails_helper'

RSpec.describe Funding, type: :model do
  let(:invalid_funding) { described_class.new }
  let(:valid_funding)    { create(:funding) }

  it 'is not valid without a person' do
    expect(invalid_funding).to_not be_valid
  end

  it 'is valid with a person' do
    expect(valid_funding).to be_valid
  end
end
