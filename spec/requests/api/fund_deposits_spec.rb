require 'rails_helper'
require 'json'

describe FundDeposit do 
  let(:person) { create(:empty_person) }

  it_behaves_like 'jsonapi show and index',
    :fund_deposits,
    :fund_deposit_with_person,
    :alt_fund_deposit_with_person,
    {amount_eq: 2000, deposit_method_code_eq: 'debin'},
    'amount,currency_code,person',
    'attachments'

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
        currency_code: "usd",
        deposit_method_code: "bank",
        external_id: 1
      }

      api_response.data.relationships.person.data.id.should == person.id.to_s
    end
  end

  describe 'Updating a person fund deposit' do 
    it 'updates the fund info when deposit exists' do 
      fund_deposit = create(:full_fund_deposit, person: person)

      api_update "/fund_deposits/#{fund_deposit.id}", {
        type: 'fund_deposits',
        id: fund_deposit.id,
        attributes: {amount: 20000.00}
      }

      api_response.data.attributes.amount.should == '20000.0'
    end
  end
end

