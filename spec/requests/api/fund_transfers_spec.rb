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

  describe "When filter by admin tags" do
    let(:admin_user) { create(:admin_user) }

    before :each do
      admin_user
    end

    it "allow fund transfer creation only with person valid admin tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:alt_full_person_tagging).person
      person3 = create(:empty_person)

      admin_user.tags << person1.tags.first

      attributes = attributes_for(:full_fund_transfer)

      expect do
        api_create '/fund_transfers',
          type: 'fund_transfers',
          attributes: attributes,
          relationships: {
            source_person: { data: { id: person1.id, type: 'people' } },
            target_person: { data: { id: person3.id, type: 'people' } }
          }
      end.to change { FundTransfer.count }.by(1)

      fund = FundTransfer.last
      expect(api_response.data.id).to eq(fund.id.to_s)

      expect do
        api_create '/fund_transfers', {
          type: 'fund_transfers',
          attributes: attributes,
          relationships: {
            source_person: { data: { id: person2.id, type: 'people' } },
            target_person: { data: { id: person3.id, type: 'people' } }
          }
        }, 404
      end.to change { FundTransfer.count }.by(0)

      expect(fund).to eq(FundTransfer.last)

      admin_user.tags << person2.tags.first
      

      expect do
        api_create '/fund_transfers',
          type: 'fund_transfers',
          attributes: attributes,
          relationships: {
            source_person: { data: { id: person1.id, type: 'people' } },
            target_person: { data: { id: person3.id, type: 'people' } }
          }
      end.to change { FundTransfer.count }.by(1)

      fund = FundTransfer.last
      expect(api_response.data.id).to eq(fund.id.to_s)

      expect do
        api_create '/fund_transfers',
          type: 'fund_transfers',
          attributes: attributes,
          relationships: {
            source_person: { data: { id: person2.id, type: 'people' } },
            target_person: { data: { id: person3.id, type: 'people' } }
          }
      end.to change { FundTransfer.count }.by(1)

      fund = FundTransfer.last
      expect(api_response.data.id).to eq(fund.id.to_s)
    end

    it "allow fund transfer creation with person tags if admin has no tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:empty_person)

      attributes = attributes_for(:full_fund_transfer)

      expect do
        api_create '/fund_transfers',
          type: 'fund_transfers',
          attributes: attributes,
          relationships: {
            source_person: { data: { id: person1.id, type: 'people' } },
            target_person: { data: { id: person2.id, type: 'people' } }
          }
      end.to change { FundTransfer.count }.by(1)
    end

    it "allow fund transfer creation without person tags if admin has no tags" do
      person1 = create(:empty_person)
      person2 = create(:empty_person)

      attributes = attributes_for(:full_fund_transfer)

      expect do
        api_create '/fund_transfers',
          type: 'fund_transfers',
          attributes: attributes,
          relationships: {
            source_person: { data: { id: person1.id, type: 'people' } },
            target_person: { data: { id: person2.id, type: 'people' } }
          }
      end.to change { FundTransfer.count }.by(1)
    end

    it "allow fund transfer creation without person tags if admin has tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:empty_person)

      attributes = attributes_for(:full_fund_transfer)

      admin_user.tags << person1.tags.first

      expect do
        api_create '/fund_transfers',
          type: 'fund_transfers',
          attributes: attributes,
          relationships: {
            source_person: { data: { id: person1.id, type: 'people' } },
            target_person: { data: { id: person2.id, type: 'people' } }
          }
      end.to change { FundTransfer.count }.by(1)
    end

    it "Update a fund transfer with person tags if admin has tags" do
      fund_transfer1, fund_transfer2, fund_transfer3, fund_transfer4 = setup_for_admin_tags_spec
      person1 = fund_transfer1.source_person
      person3 = fund_transfer3.source_person

      admin_user.tags << person1.tags.first

      api_update "/fund_transfers/#{fund_transfer1.id}",
        type: 'fund_transfers',
        id: fund_transfer1.id,
        attributes: {
          amount: 20_000.00
        }

      api_update "/fund_transfers/#{fund_transfer2.id}",
        type: 'fund_transfers',
        id: fund_transfer2.id,
        attributes: {
          amount: 20_000.00
        }

      admin_user.tags.delete person3.tags.last
      api_update "/fund_transfers/#{fund_transfer3.id}", {
        type: 'fund_transfers',
        id: fund_transfer3.id,
        attributes: {
          amount: 20_000.00
        }
      }, 404

      api_update "/fund_transfers/#{fund_transfer4.id}",
        type: 'fund_transfers',
        id: fund_transfer4.id,
        attributes: {
          amount: 20_000.00
        }

      admin_user.tags << person3.tags.first

      api_update "/fund_transfers/#{fund_transfer3.id}",
        type: 'fund_transfers',
        id: fund_transfer3.id,
        attributes: {
          amount: 20_000.00
        }
    end

    it "show fund transfer with admin user active tags" do
      fund_transfer1, fund_transfer2, fund_transfer3, fund_transfer4 = setup_for_admin_tags_spec
      person1 = fund_transfer1.source_person
      person3 = fund_transfer3.source_person

      api_get("/fund_transfers/#{fund_transfer1.id}")
      api_get("/fund_transfers/#{fund_transfer2.id}")
      api_get("/fund_transfers/#{fund_transfer3.id}")
      api_get("/fund_transfers/#{fund_transfer4.id}")

      admin_user.tags << person1.tags.first

      api_get("/fund_transfers/#{fund_transfer1.id}")
      api_get("/fund_transfers/#{fund_transfer2.id}")
      api_get("/fund_transfers/#{fund_transfer3.id}", {}, 404)
      api_get("/fund_transfers/#{fund_transfer4.id}")

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first

      api_get("/fund_transfers/#{fund_transfer1.id}", {}, 404)
      api_get("/fund_transfers/#{fund_transfer2.id}")
      api_get("/fund_transfers/#{fund_transfer3.id}")
      api_get("/fund_transfers/#{fund_transfer4.id}")

      admin_user.tags << person1.tags.first

      api_get("/fund_transfers/#{fund_transfer1.id}")
      api_get("/fund_transfers/#{fund_transfer2.id}")
      api_get("/fund_transfers/#{fund_transfer3.id}")
      api_get("/fund_transfers/#{fund_transfer4.id}")
    end

    it "index fund transfer with admin user active tags" do
      fund_transfer1, fund_transfer2, fund_transfer3, fund_transfer4 = setup_for_admin_tags_spec
      person1 = fund_transfer1.source_person
      person3 = fund_transfer3.source_person

      api_get("/fund_transfers/")
      expect(api_response.meta.total_items).to eq(4)
      expect(api_response.data[0].id).to eq(fund_transfer4.id.to_s)
      expect(api_response.data[1].id).to eq(fund_transfer3.id.to_s)
      expect(api_response.data[2].id).to eq(fund_transfer2.id.to_s)
      expect(api_response.data[3].id).to eq(fund_transfer1.id.to_s)

      admin_user.tags << person1.tags.first

      api_get("/fund_transfers/")
      expect(api_response.meta.total_items).to eq(3)
      expect(api_response.data[0].id).to eq(fund_transfer4.id.to_s)
      expect(api_response.data[1].id).to eq(fund_transfer2.id.to_s)
      expect(api_response.data[2].id).to eq(fund_transfer1.id.to_s)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first

      api_get("/fund_transfers/")
      expect(api_response.meta.total_items).to eq(3)
      expect(api_response.data[0].id).to eq(fund_transfer4.id.to_s)
      expect(api_response.data[1].id).to eq(fund_transfer3.id.to_s)
      expect(api_response.data[2].id).to eq(fund_transfer2.id.to_s)

      admin_user.tags << person1.tags.first

      api_get("/fund_transfers/")
      expect(api_response.meta.total_items).to eq(4)
      expect(api_response.data[0].id).to eq(fund_transfer4.id.to_s)
      expect(api_response.data[1].id).to eq(fund_transfer3.id.to_s)
      expect(api_response.data[2].id).to eq(fund_transfer2.id.to_s)
      expect(api_response.data[3].id).to eq(fund_transfer1.id.to_s)
    end

    def setup_for_admin_tags_spec
      person1 = create(:full_person_tagging).person
      person2 = create(:empty_person)
      person3 = create(:alt_full_person_tagging).person
      person4 = create(:empty_person)
      person4.tags << person1.tags.first
      person4.tags << person3.tags.first
      person5 = create(:empty_person)

      fund_transfer1 = create(:full_fund_transfer, source_person: person1,
        target_person: person5)
      fund_transfer2 = create(:full_fund_transfer, source_person: person2,
        target_person: person5)
      fund_transfer3 = create(:full_fund_transfer, source_person: person3,
        target_person: person5)
      fund_transfer4 = create(:full_fund_transfer, source_person: person4,
        target_person: person5)

      [fund_transfer1, fund_transfer2, fund_transfer3, fund_transfer4]
    end
  end
end
