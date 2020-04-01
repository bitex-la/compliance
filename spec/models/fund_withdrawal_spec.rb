require 'rails_helper'

RSpec.describe FundWithdrawal, type: :model do
  let(:person) { create(:empty_person) }

  it 'validates non null fields' do
    invalid = FundWithdrawal.new
    expect(invalid).not_to be_valid
    expect(invalid.errors.keys).to match_array(%i[
      currency external_id person amount exchange_rate_adjusted_amount withdrawal_date
    ])
  end

  it 'is valid with a person, currency and withdrawal_date' do
    expect(create(:fund_withdrawal, person: person)).to be_valid
  end

  it 'logs creation of fund withdrawals' do
    object = create(:full_fund_withdrawal, person: person)
    assert_logging(object, :create_entity, 1)
  end

  it 'is not valid if withdrawal_date is in the future' do
    object = build(:fund_withdrawal, person: person, withdrawal_date: 1.hour.from_now)
    expect(object).to_not be_valid
    expect(object.errors.messages.keys.first).to eq(:withdrawal_date)
  end

  it 'is not valid if withdrawal_date is nil' do
    object = build(:fund_withdrawal, person: person, withdrawal_date: nil)
    expect(object).to_not be_valid
    expect(object.errors.messages.keys.first).to eq(:withdrawal_date)
  end
end
