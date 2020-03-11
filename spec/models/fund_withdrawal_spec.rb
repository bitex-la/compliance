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
end