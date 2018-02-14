require 'rails_helper'

RSpec.describe Quotum, type: :model do
  let(:invalid_quota) { described_class.new }
  let(:valid_quota)   { create(:quota) }

  it 'is not valid without a person' do
    expect(invalid_quota).to_not be_valid
  end

  it 'is valid with a person' do
    expect(valid_quota).to be_valid
  end
end
