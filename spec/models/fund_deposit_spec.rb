require 'rails_helper'

RSpec.describe FundDeposit, type: :model do
  let(:person) { create(:empty_person) }
  let(:invalid_fund_deposit) { described_class.new }
  let(:valid_fund_deposit) { 
    create(:fund_deposit,
      person: person,
      currency: Currency.find_by_code('usd'),
      deposit_method: DepositMethod.find_by_code('bank'),
      external_id: 1
  )}

  it 'is not valid without a person' do
    expect(invalid_fund_deposit).to_not be_valid
  end

  it 'is valid with a person, currency and deposit method' do
    expect(valid_fund_deposit).to be_valid
  end
end
