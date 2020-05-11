require 'rails_helper'
require 'json'

describe FundTransfer do
  let(:source_person) { create(:empty_person) }
  let(:target_person) { create(:empty_person) }

  it_behaves_like 'jsonapi show and index',
    :fund_transfers,
    :fund_transfer_with_people,
    :alt_fund_transfer_with_people,
    {amount_eq: 45000},
    'amount,currency_code,transfer_date',
    'attachments'

  it_behaves_like 'max people allowed request limit',
    :fund_transfers,
    :fund_transfer_with_people

  describe 'Creating a new FundTransfer' do
    it 'responds with (422) when body is empty' do
      api_create "/fund_transfers", {}, 422
    end

    it 'creates a new fund transfer for a person' do
      attributes = attributes_for(:full_fund_transfer)

      api_create "/fund_transfers", {
        type: 'fund_transfers',
        attributes: attributes,
        relationships: {
          source_person: {data: {id: source_person.id, type: 'people'}},
          target_person: {data: {id: target_person.id, type: 'people'}}
        }
      }

      api_response.data.attributes.to_h.should >= {
        amount: '1000.0',
        exchange_rate_adjusted_amount: '1000.0',
        currency_code: 'usd',
        transfer_date: attributes[:transfer_date].change(usec: 0).as_json
      }

      expect(api_response.data.relationships.source_person.data.id).to eq source_person.id.to_s
      expect(api_response.data.relationships.target_person.data.id).to eq target_person.id.to_s
    end
  end

  describe 'Updating a person fund transfer' do
    it 'updates the fund info when transfer exists' do
      fund_transfer = create(:full_fund_transfer,
                             source_person: source_person,
                             target_person: target_person)

      api_update "/fund_transfers/#{fund_transfer.id}", {
        type: 'fund_transfers',
        id: fund_transfer.id,
        attributes: {amount: 20000.35, external_id: '2'}
      }

      expect(api_response.data.attributes.amount).to eq '20000.35'
      expect(api_response.data.attributes.external_id).to eq '2'
      expect(api_response.data.attributes.transfer_date).to eq fund_transfer.transfer_date.as_json
    end
  end
end

