require 'rails_helper'

RSpec.describe FundDepositSeed, type: :model do
  let(:invalid_seed) { described_class.new }
  let(:valid_seed)   { 
    create(:fund_deposit_seed,
      currency: Currency.find_by_code('usd'),
      deposit_method: DepositMethod.find_by_code('bank'),
      external_id: 1
    )
  }

  it 'is not valid without an issue' do
    expect(invalid_seed).to_not be_valid
  end

  it 'is valid with an issue' do
    expect(valid_seed).to be_valid
  end
end
