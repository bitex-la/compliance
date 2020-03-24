require 'rails_helper'

RSpec.describe FundTransfer, type: :model do
  let(:source_person) { create(:empty_person) }
  let(:target_person) { create(:empty_person) }

  it 'validates non null fields' do
    invalid = FundTransfer.new
    expect(invalid).not_to be_valid
    expect(invalid.errors.keys).to match_array(%i[
      currency external_id person amount exchange_rate_adjusted_amount transfer_date
    ])
  end

  it 'is valid with a person, currency and transfer_date' do
    expect(create(:fund_transfer,
                  source_person: source_person,
                  target_person: target_person)
                 ).to be_valid
  end

  it 'logs creation of fund transfers' do
    object = create(:full_fund_transfer,
                    source_person: source_person,
                    target_person: target_person
                   )
    assert_logging(object, :create_entity, 1)
  end
end
