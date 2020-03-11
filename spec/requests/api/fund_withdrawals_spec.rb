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

  describe "When filter by admin tags" do
    let(:admin_user) { create(:admin_user) }

    before :each do
      admin_user.tags.clear
      admin_user.save!
    end

    it "allow fund withdrawal creation only with person valid admin tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:alt_full_person_tagging).person

      admin_user.tags << person1.tags.first
      admin_user.save!

      attributes = attributes_for(:full_fund_withdrawal)

      expect do
        api_create '/fund_withdrawals',
          type: 'fund_withdrawals',
          attributes: attributes,
          relationships: {
            person: { data: { id: person1.id, type: 'people' } }
          }
      end.to change { FundWithdrawal.count }.by(1)

      fund = FundWithdrawal.last
      expect(api_response.data.id).to eq(fund.id.to_s)

      expect do
        api_create '/fund_withdrawals', {
          type: 'fund_withdrawals',
          attributes: attributes,
          relationships: {
            person: { data: { id: person2.id, type: 'people' } }
          }
        }, 404
      end.to change { FundWithdrawal.count }.by(0)

      expect(fund).to eq(FundWithdrawal.last)

      admin_user.tags << person2.tags.first
      admin_user.save!

      expect do
        api_create '/fund_withdrawals',
          type: 'fund_withdrawals',
          attributes: attributes,
          relationships: {
            person: { data: { id: person1.id, type: 'people' } }
          }
      end.to change { FundWithdrawal.count }.by(1)

      fund = FundWithdrawal.last
      expect(api_response.data.id).to eq(fund.id.to_s)

      expect do
        api_create '/fund_withdrawals', {
          type: 'fund_withdrawals',
          attributes: attributes,
          relationships: {
            person: { data: { id: person2.id, type: 'people' } }
          }
        }
      end.to change { FundWithdrawal.count }.by(1)

      fund = FundWithdrawal.last
      expect(api_response.data.id).to eq(fund.id.to_s)
    end

    it "allow fund withdrawal creation with person tags if admin has no tags" do
      person = create(:full_person_tagging).person

      attributes = attributes_for(:full_fund_withdrawal)

      expect do
        api_create '/fund_withdrawals',
          type: 'fund_withdrawals',
          attributes: attributes,
          relationships: {
            person: { data: { id: person.id, type: 'people' } }
          }
      end.to change { FundWithdrawal.count }.by(1)
    end

    it "allow fund withdrawal creation without person tags if admin has no tags" do
      person = create(:empty_person)

      attributes = attributes_for(:full_fund_withdrawal)

      expect do
        api_create '/fund_withdrawals',
          type: 'fund_withdrawals',
          attributes: attributes,
          relationships: {
            person: { data: { id: person.id, type: 'people' } }
          }
      end.to change { FundWithdrawal.count }.by(1)
    end

    it "allow fund withdrawal creation without person tags if admin has tags" do
      person1 = create(:full_person_tagging).person

      attributes = attributes_for(:full_fund_withdrawal)

      admin_user.tags << person1.tags.first
      admin_user.save!

      expect do
        api_create '/fund_withdrawals',
          type: 'fund_withdrawals',
          attributes: attributes,
          relationships: {
            person: { data: { id: person.id, type: 'people' } }
          }
      end.to change { FundWithdrawal.count }.by(1)
    end

    it "Update a fund deposit with person tags if admin has tags" do
      fund1, fund2, fund3, fund4 = setup_for_admin_tags_spec
      person1 = fund1.person
      person3 = fund3.person

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_update "/fund_withdrawals/#{fund1.id}",
        type: 'fund_withdrawals',
        id: fund1.id,
        attributes: {
          amount: 20_000.00,
          country: 'BR'
        }

      api_update "/fund_withdrawals/#{fund2.id}",
        type: 'fund_withdrawals',
        id: fund2.id,
        attributes: {
          amount: 20_000.00,
          country: 'BR'
        }

      api_update "/fund_withdrawals/#{fund3.id}", {
        type: 'fund_withdrawals',
        id: fund3.id,
        attributes: {
          amount: 20_000.00,
          country: 'BR'
        }
      }, 404

      api_update "/fund_withdrawals/#{fund4.id}",
        type: 'fund_withdrawals',
        id: fund4.id,
        attributes: {
          amount: 20_000.00,
          country: 'BR'
        }

      admin_user.tags << person3.tags.first
      admin_user.save!

      api_update "/fund_withdrawals/#{fund3.id}",
        type: 'fund_withdrawals',
        id: fund3.id,
        attributes: {
          amount: 20_000.00,
          country: 'BR'
        }
    end

    it "show fund withdrawal with admin user active tags" do
      fund1, fund2, fund3, fund4 = setup_for_admin_tags_spec
      person1 = fund1.person
      person3 = fund3.person

      api_get("/fund_withdrawals/#{fund1.id}")
      api_get("/fund_withdrawals/#{fund2.id}")
      api_get("/fund_withdrawals/#{fund3.id}")
      api_get("/fund_withdrawals/#{fund4.id}")

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/fund_withdrawals/#{fund1.id}")
      api_get("/fund_withdrawals/#{fund2.id}")
      api_get("/fund_withdrawals/#{fund3.id}", {}, 404)
      api_get("/fund_withdrawals/#{fund4.id}")

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      api_get("/fund_withdrawals/#{fund1.id}", {}, 404)
      api_get("/fund_withdrawals/#{fund2.id}")
      api_get("/fund_withdrawals/#{fund3.id}")
      api_get("/fund_withdrawals/#{fund4.id}")

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/fund_withdrawals/#{fund1.id}")
      api_get("/fund_withdrawals/#{fund2.id}")
      api_get("/fund_withdrawals/#{fund3.id}")
      api_get("/fund_withdrawals/#{fund4.id}")
    end

    it "index fund withdrawal with admin user active tags" do
      fund1, fund2, fund3, fund4 = setup_for_admin_tags_spec
      person1 = fund1.person
      person3 = fund3.person

      api_get("/fund_withdrawals/")
      expect(api_response.meta.total_items).to eq(4)
      expect(api_response.data[0].id).to eq(fund4.id.to_s)
      expect(api_response.data[1].id).to eq(fund3.id.to_s)
      expect(api_response.data[2].id).to eq(fund2.id.to_s)
      expect(api_response.data[3].id).to eq(fund1.id.to_s)

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/fund_withdrawals/")
      expect(api_response.meta.total_items).to eq(3)
      expect(api_response.data[0].id).to eq(fund4.id.to_s)
      expect(api_response.data[1].id).to eq(fund2.id.to_s)
      expect(api_response.data[2].id).to eq(fund1.id.to_s)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      api_get("/fund_withdrawals/")
      expect(api_response.meta.total_items).to eq(3)
      expect(api_response.data[0].id).to eq(fund4.id.to_s)
      expect(api_response.data[1].id).to eq(fund3.id.to_s)
      expect(api_response.data[2].id).to eq(fund2.id.to_s)

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/fund_withdrawals/")
      expect(api_response.meta.total_items).to eq(4)
      expect(api_response.data[0].id).to eq(fund4.id.to_s)
      expect(api_response.data[1].id).to eq(fund3.id.to_s)
      expect(api_response.data[2].id).to eq(fund2.id.to_s)
      expect(api_response.data[3].id).to eq(fund1.id.to_s)
    end

    def setup_for_admin_tags_spec
      person1 = create(:full_person_tagging).person
      person2 = create(:empty_person)
      person3 = create(:alt_full_person_tagging).person
      person4 = create(:empty_person)
      person4.tags << person1.tags.first
      person4.tags << person3.tags.first

      fund1 = create(:full_fund_withdrawal, person: person1)
      fund2 = create(:full_fund_withdrawal, person: person2)
      fund3 = create(:full_fund_withdrawal, person: person3)
      fund4 = create(:full_fund_withdrawal, person: person4)

      [fund1, fund2, fund3, fund4]
    end
  end
end
