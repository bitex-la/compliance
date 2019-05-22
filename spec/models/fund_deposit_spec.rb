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

  describe 'when customer changes regularity' do
    
    it 'person changes regularity by amount funded' do
      expect(person.regularity).to eq PersonRegularity.none
      
      create(:alt_fund_deposit, person: person)
      expect(person.reload.regularity).to eq PersonRegularity.none
     
      create(:full_fund_deposit, person: person, amount: 2500)
      expect(person.reload.regularity).to eq PersonRegularity.low

      assert_logging(person, :update_person_regularity, 1) do |l|
        fund_deposits = l.data.data.relationships.fund_deposits.data
        expect(fund_deposits.size).to eq 2
        
        expect(l.data.included.find {|x| 
          x.type == "regularities" && 
          x.id == PersonRegularity.low.id.to_s
        }).not_to be_nil
      end
    
      create(:alt_fund_deposit, person: person)
      expect(person.reload.regularity).to eq PersonRegularity.low

      create(:full_fund_deposit, person: person, amount: 20000)
      expect(person.reload.regularity).to eq PersonRegularity.high

      assert_logging(person, :update_person_regularity, 2) do |l|
        fund_deposits = l.data.data.relationships.fund_deposits.data
        expect(fund_deposits.size).to eq 4
        
        expect(l.data.included.find {|x| 
          x.type == "regularities" && 
          x.id == PersonRegularity.high.id.to_s
        }).not_to be_nil
      end

    end
    
    it 'person changes regularity by funding repeatedly' do
      expect(person.regularity).to eq PersonRegularity.none
     
      create(:alt_fund_deposit, person: person, amount:1)
      expect(person.reload.regularity).to eq PersonRegularity.none
      
      create(:full_fund_deposit, person: person, amount:1)
      expect(person.reload.regularity).to eq PersonRegularity.none

      create(:alt_fund_deposit, person: person, amount:1)
      expect(person.reload.regularity).to eq PersonRegularity.low

      assert_logging(person, :update_person_regularity, 1) do |l|
        fund_deposits = l.data.data.relationships.fund_deposits.data
        expect(fund_deposits.size).to eq 3
        
        expect(l.data.included.find {|x| 
          x.type == "regularities" && 
          x.id == PersonRegularity.low.id.to_s
        }).not_to be_nil
      end

      6.times do 
        create(:alt_fund_deposit, person: person, amount:1)
        expect(person.reload.regularity).to eq PersonRegularity.low
      end
      
      create(:full_fund_deposit, person: person, amount: 1)
      expect(person.reload.regularity).to eq PersonRegularity.high
      
      assert_logging(person, :update_person_regularity, 2) do |l|
        fund_deposits = l.data.data.relationships.fund_deposits.data
        expect(fund_deposits.size).to eq 10
        
        expect(l.data.included.find {|x| 
          x.type == "regularities" && 
          x.id == PersonRegularity.high.id.to_s
        }).not_to be_nil
      end
    end

    it 'low_regular person can become high_regular by amount funded' do
      pending
      fail
    end
    
    it 'low_regular person can become high_regular by funding repeatedly' do
      pending
      fail
    end

  end
end
