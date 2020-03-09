require 'rails_helper'
require 'json'

describe FundDeposit do 
  let(:person) { create(:empty_person) }

  it_behaves_like 'jsonapi show and index',
    :fund_deposits,
    :fund_deposit_with_person,
    :alt_fund_deposit_with_person,
    {amount_eq: 45000, deposit_method_code_eq: 'debin'},
    'amount,currency_code,person',
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
        external_id: "1"
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

  describe "When filter by admin tags" do
    let(:admin_user) { create(:admin_user) }

    before :each do
      admin_user.tags.clear
      admin_user.save!
    end

    it "allow fund deposit creation only with person valid admin tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:alt_full_person_tagging).person

      admin_user.tags << person1.tags.first
      admin_user.save!

      attributes = attributes_for(:full_fund_deposit)

      expect do
        api_create '/fund_deposits',
          type: 'fund_deposits',
          attributes: attributes,
          relationships: {
            person: { data: { id: person1.id, type: 'people' } }
          }
      end.to change { FundDeposit.count }.by(1)

      expect do
        api_create '/fund_deposits', {
          type: 'fund_deposits',
          attributes: attributes,
          relationships: {
            person: { data: { id: person2.id, type: 'people' } }
          }
        }, 404
      end.to change { FundDeposit.count }.by(0)

      admin_user.tags << person2.tags.first
      admin_user.save!

      expect do
        api_create '/fund_deposits',
          type: 'fund_deposits',
          attributes: attributes,
          relationships: {
            person: { data: { id: person1.id, type: 'people' } }
          }
      end.to change { FundDeposit.count }.by(1)

      expect do
        api_create '/fund_deposits', {
          type: 'fund_deposits',
          attributes: attributes,
          relationships: {
            person: { data: { id: person2.id, type: 'people' } }
          }
        }
      end.to change { FundDeposit.count }.by(1)
    end

    it "allow fund deposit creation with person tags if admin has no tags" do
      person = create(:full_person_tagging).person

      attributes = attributes_for(:full_fund_deposit)

      expect do
        api_create '/fund_deposits',
          type: 'fund_deposits',
          attributes: attributes,
          relationships: {
            person: { data: { id: person.id, type: 'people' } }
          }
      end.to change { FundDeposit.count }.by(1)
    end

    it "allow fund deposit creation without person tags if admin has no tags" do
      person = create(:empty_person)

      attributes = attributes_for(:full_fund_deposit)

      expect do
        api_create '/fund_deposits',
          type: 'fund_deposits',
          attributes: attributes,
          relationships: {
            person: { data: { id: person.id, type: 'people' } }
          }
      end.to change { FundDeposit.count }.by(1)
    end

    it "allow fund deposit creation without person tags if admin has tags" do
      person1 = create(:full_person_tagging).person

      attributes = attributes_for(:full_fund_deposit)

      admin_user.tags << person1.tags.first
      admin_user.save!

      expect do
        api_create '/fund_deposits',
          type: 'fund_deposits',
          attributes: attributes,
          relationships: {
            person: { data: { id: person.id, type: 'people' } }
          }
      end.to change { FundDeposit.count }.by(1)
    end

    it "show fund deposit with admin user active tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:empty_person)
      person3 = create(:alt_full_person_tagging).person
      person4 = create(:empty_person)
      person4.tags << person1.tags.first
      person4.tags << person3.tags.first

      fund_deposit1 = create(:full_fund_deposit, person: person1)
      fund_deposit2 = create(:full_fund_deposit, person: person2)
      fund_deposit3 = create(:full_fund_deposit, person: person3)
      fund_deposit4 = create(:full_fund_deposit, person: person4)

      api_get("/fund_deposits/#{fund_deposit1.id}")
      api_get("/fund_deposits/#{fund_deposit2.id}")
      api_get("/fund_deposits/#{fund_deposit3.id}")
      api_get("/fund_deposits/#{fund_deposit4.id}")

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/fund_deposits/#{fund_deposit1.id}")
      api_get("/fund_deposits/#{fund_deposit2.id}")
      api_get("/fund_deposits/#{fund_deposit3.id}", {}, 404)
      api_get("/fund_deposits/#{fund_deposit4.id}")

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      api_get("/fund_deposits/#{fund_deposit1.id}", {}, 404)
      api_get("/fund_deposits/#{fund_deposit2.id}")
      api_get("/fund_deposits/#{fund_deposit3.id}")
      api_get("/fund_deposits/#{fund_deposit4.id}")

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/fund_deposits/#{fund_deposit1.id}")
      api_get("/fund_deposits/#{fund_deposit2.id}")
      api_get("/fund_deposits/#{fund_deposit3.id}")
      api_get("/fund_deposits/#{fund_deposit4.id}")
    end

    it "index fund deposit with admin user active tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:empty_person)
      person3 = create(:alt_full_person_tagging).person
      person4 = create(:empty_person)
      person4.tags << person1.tags.first
      person4.tags << person3.tags.first

      fund_deposit1 = create(:full_fund_deposit, person: person1)
      fund_deposit2 = create(:full_fund_deposit, person: person2)
      fund_deposit3 = create(:full_fund_deposit, person: person3)
      fund_deposit4 = create(:full_fund_deposit, person: person4)

      api_get("/fund_deposits/")
      expect(api_response.meta.total_items).to eq(4)
      expect(api_response.data[0].id).to eq(fund_deposit4.id.to_s)
      expect(api_response.data[1].id).to eq(fund_deposit3.id.to_s)
      expect(api_response.data[2].id).to eq(fund_deposit2.id.to_s)
      expect(api_response.data[3].id).to eq(fund_deposit1.id.to_s)

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/fund_deposits/")
      expect(api_response.meta.total_items).to eq(3)
      expect(api_response.data[0].id).to eq(fund_deposit4.id.to_s)
      expect(api_response.data[1].id).to eq(fund_deposit2.id.to_s)
      expect(api_response.data[2].id).to eq(fund_deposit1.id.to_s)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      api_get("/fund_deposits/")
      expect(api_response.meta.total_items).to eq(3)
      expect(api_response.data[0].id).to eq(fund_deposit4.id.to_s)
      expect(api_response.data[1].id).to eq(fund_deposit3.id.to_s)
      expect(api_response.data[2].id).to eq(fund_deposit2.id.to_s)

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/fund_deposits/")
      expect(api_response.meta.total_items).to eq(4)
      expect(api_response.data[0].id).to eq(fund_deposit4.id.to_s)
      expect(api_response.data[1].id).to eq(fund_deposit3.id.to_s)
      expect(api_response.data[2].id).to eq(fund_deposit2.id.to_s)
      expect(api_response.data[3].id).to eq(fund_deposit1.id.to_s)
    end
  end
end
