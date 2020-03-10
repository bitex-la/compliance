require 'rails_helper'
require 'json'

describe FundWithdrawal do
  let(:person) { create(:empty_person) }

  it_behaves_like 'jsonapi show and index',
    :fund_withdrawals,
    :fund_withdrawal_with_person,
    :alt_fund_withdrawal_with_person,
    {amount_eq: 45000},
    'amount,currency_code,country,withdrawal_date,external_id,person',
    'attachments'

  it_behaves_like 'max people allowed request limit',
    :fund_withdrawals,
    :fund_withdrawal_with_person

  describe 'Creating a new person FundWithdrawal' do
    it 'responds with (422) when body is empty' do
      api_create "/fund_withdrawals", {}, 422
    end

    it 'creates a new fund withdrawal for a person' do
      attributes = attributes_for(:full_fund_withdrawal)

      api_create "/fund_withdrawals", {
        type: 'fund_withdrawals',
        attributes: attributes,
        relationships: {
          person: {data: {id: person.id, type: 'people'}}
        }
      }

      api_response.data.attributes.to_h.should >= {
        amount: '1000.0',
        exchange_rate_adjusted_amount: '1000.0',
        currency_code: 'usd',
        withdrawal_date: attributes[:withdrawal_date].change(usec: 0).as_json,
        country: 'AR'
      }

      api_response.data.relationships.person.data.id.should == person.id.to_s
    end
  end

  describe 'Updating a person fund withdrawal' do
    it 'updates the fund info when withdrawal exists' do
      fund_withdrawal = create(:full_fund_withdrawal, person: person)
      api_update "/fund_withdrawals/#{fund_withdrawal.id}", {
        type: 'fund_withdrawals',
        id: fund_withdrawal.id,
        attributes: {amount: 20000.00, country: 'ES', external_id: '2'}
      }

      api_response.data.attributes.amount.should == '20000.0'
      api_response.data.attributes.country.should == 'ES'
      api_response.data.attributes.external_id.should == '2'
      api_response.data.attributes.withdrawal_date.should == fund_withdrawal.withdrawal_date.as_json
    end
  end
end

