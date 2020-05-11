require 'rails_helper'
require 'json'

describe FundDeposit do
  let(:person) { create(:empty_person) }

  it_behaves_like 'jsonapi show and index',
    :fund_deposits,
    :fund_deposit_with_person,
    :alt_fund_deposit_with_person,
    {amount_eq: 45000, deposit_method_code_eq: 'debin'},
    'amount,currency_code,country,deposit_date,person',
    'attachments'

  it_behaves_like 'max people allowed request limit',
    :fund_deposits,
    :fund_deposit_with_person

  describe 'Creating a new person FundDeposit' do
    it 'responds with (422) when body is empty' do
      api_create "/fund_deposits", {}, 422
    end

    it 'creates a new fund deposit for a person' do
      attributes = attributes_for(:full_fund_deposit)

      api_create "/fund_deposits", {
        type: 'fund_deposits',
        attributes: attributes,
        relationships: {
          person: {data: {id: person.id, type: 'people'}}
        }
      }

      api_response.data.attributes.to_h.should >= {
        amount: '1000.0',
        exchange_rate_adjusted_amount: '1000.0',
        currency_code: "usd",
        deposit_method_code: "bank",
        external_id: "1",
        deposit_date: attributes[:deposit_date].change(usec: 0).as_json,
        country: "AR"
      }

      api_response.data.relationships.person.data.id.should == person.id.to_s
    end
  end

  describe 'Updating a person fund deposit' do
    it 'updates the fund info when deposit exists' do
      fund_deposit = create(:full_fund_deposit, person: person)

      new_deposit_date = Time.now.utc.change(usec: 0)

      api_update "/fund_deposits/#{fund_deposit.id}", {
        type: 'fund_deposits',
        id: fund_deposit.id,
        attributes: {
          amount: 20_000.36,
          country: 'BR',
          deposit_date: new_deposit_date
        }
      }

      attributes = api_response.data.attributes
      expect(attributes.amount).to eq('20000.36')
      expect(attributes.country).to eq('BR')
      expect(attributes.deposit_date).to eq(new_deposit_date.as_json)
    end
  end
end
