require 'rails_helper'
require 'helpers/api/api_helper'
require 'helpers/api/entities_helper'
require 'json'

describe FundDeposit do 
  let(:person) { create(:empty_person) }
  let(:admin_user) { create(:admin_user) }

  describe 'Creating a new person FundDeposit' do
    it 'responds with an Unprocessable Entity HTTP code (422) when body is empty' do
      post "/api/people/#{person.id}/fund_deposits",
        params: {},
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }
      assert_response 422
    end

    it 'creates a new fund deposit for a person' do
      fund_deposit  = Api::EntitiesHelper.person_with_fund_deposit
      post "/api/people/#{person.id}/fund_deposits",
        params: fund_deposit,
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      FundDeposit.count.should == 1
      Person.first.fund_deposits.first.should ==  FundDeposit.last
      assert_response 201
      assert_logging(FundDeposit.last, :create_entity, 1)
    end
  end

  describe 'Updating a person fund deposit' do 
    it 'updates the fund info when deposit exists' do 
      full_natural_person = create(:full_natural_person)
      fund_deposit  = Api::EntitiesHelper.person_with_fund_deposit

      fund_deposit[:data][:id] = Person.first.fund_deposits.first.id
      fund_deposit[:data][:attributes][:amount] = 20000.00

      put "/api/people/#{full_natural_person.id}/fund_deposits/#{fund_deposit[:data][:id]}",
        params: fund_deposit,
        headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

      assert_response 200
      assert_logging(FundDeposit.last, :create_entity, 1)
    end
  end
end

