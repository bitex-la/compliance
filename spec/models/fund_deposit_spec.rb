require 'rails_helper'

RSpec.describe FundDeposit, type: :model do
  let(:person) { create(:empty_person) }

  it 'validates non null fields' do
    invalid = FundDeposit.new
    expect(invalid).not_to be_valid
    expect(invalid.errors.keys).to match_array(%i[
      external_id deposit_method currency person amount
      exchange_rate_adjusted_amount])
  end

  it 'is valid with a person, currency and deposit method' do
    expect(create(:fund_deposit, person: person)).to be_valid
  end

  it 'logs creation of fund deposits' do
    object = create(:full_fund_deposit, person: person)
    assert_logging(object, :create_entity, 1)
  end

  describe 'when customer becomes a regular' do
    it 'can become a regular by amount funded' do
      pending
      fail
    end

    it 'can become a regular by funding repeatedly' do
      pending
      fail
    end
  end
end
