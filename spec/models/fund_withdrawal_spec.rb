require 'rails_helper'

RSpec.describe FundWithdrawal, type: :model do
  let(:person) { create(:empty_person) }

  it 'validates non null fields' do
    invalid = FundWithdrawal.new
    expect(invalid).not_to be_valid
    expect(invalid.errors.keys).to match_array(%i[
      currency external_id person amount exchange_rate_adjusted_amount withdrawal_date
    ])
  end

  it 'is valid with a person, currency and withdrawal_date' do
    expect(create(:fund_withdrawal, person: person)).to be_valid
  end

  it 'logs creation of fund withdrawals' do
    object = create(:full_fund_withdrawal, person: person)
    assert_logging(object, :create_entity, 1)
  end

  describe "When filter by admin tags" do
    let(:admin_user) { AdminUser.current_admin_user = create(:admin_user) }

    before :each do
      admin_user.tags.clear
      admin_user.save!
    end

    it "allow fund withdrawal creation only with person valid admin tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:alt_full_person_tagging).person

      admin_user.tags << person1.tags.first
      admin_user.save!

      expect do
        fund_withdrawal = FundWithdrawal.new(person: Person.find(person1.id))
        fund_withdrawal.amount = 1000
        fund_withdrawal.exchange_rate_adjusted_amount = 1000
        fund_withdrawal.currency_code = 'usd'
        fund_withdrawal.external_id = '1'
        fund_withdrawal.country = 'AR'
        fund_withdrawal.withdrawal_date = DateTime.now.utc
        fund_withdrawal.save!
      end.to change { FundWithdrawal.count }.by(1)

      expect { Person.find(person2.id) }.to raise_error(ActiveRecord::RecordNotFound)

      admin_user.tags << person2.tags.first
      admin_user.save!

      expect do
        fund_withdrawal = FundWithdrawal.new(person: Person.find(person1.id))
        fund_withdrawal.amount = 1000
        fund_withdrawal.exchange_rate_adjusted_amount = 1000
        fund_withdrawal.currency_code = 'usd'
        fund_withdrawal.external_id = '1'
        fund_withdrawal.country = 'AR'
        fund_withdrawal.withdrawal_date = DateTime.now.utc
        fund_withdrawal.save!
      end.to change { FundWithdrawal.count }.by(1)

      expect do
        fund_withdrawal = FundWithdrawal.new(person: Person.find(person2.id))
        fund_withdrawal.amount = 1000
        fund_withdrawal.exchange_rate_adjusted_amount = 1000
        fund_withdrawal.currency_code = 'usd'
        fund_withdrawal.external_id = '1'
        fund_withdrawal.country = 'AR'
        fund_withdrawal.withdrawal_date = DateTime.now.utc
        fund_withdrawal.save!
      end.to change { FundWithdrawal.count }.by(1)
    end

    it "allow fund withdrawal creation with person tags if admin has no tags" do
      person = create(:full_person_tagging).person

      expect do
        fund_withdrawal = FundWithdrawal.new(person: Person.find(person.id))
        fund_withdrawal.amount = 1000
        fund_withdrawal.exchange_rate_adjusted_amount = 1000
        fund_withdrawal.currency_code = 'usd'
        fund_withdrawal.external_id = '1'
        fund_withdrawal.country = 'AR'
        fund_withdrawal.withdrawal_date = DateTime.now.utc
        fund_withdrawal.save!
      end.to change { FundWithdrawal.count }.by(1)
    end

    it "allow fund withdrawal creation without person tags if admin has no tags" do
      person = create(:empty_person)

      expect do
        fund_withdrawal = FundWithdrawal.new(person: Person.find(person.id))
        fund_withdrawal.amount = 1000
        fund_withdrawal.exchange_rate_adjusted_amount = 1000
        fund_withdrawal.currency_code = 'usd'
        fund_withdrawal.external_id = '1'
        fund_withdrawal.country = 'AR'
        fund_withdrawal.withdrawal_date = DateTime.now.utc
        fund_withdrawal.save!
      end.to change { FundWithdrawal.count }.by(1)
    end

    it "allow fund withdrawal creation without person tags if admin has tags" do
      person1 = create(:full_person_tagging).person

      admin_user.tags << person1.tags.first
      admin_user.save!

      expect do
        fund_withdrawal = FundWithdrawal.new(person: Person.find(person.id))
        fund_withdrawal.amount = 1000
        fund_withdrawal.exchange_rate_adjusted_amount = 1000
        fund_withdrawal.currency_code = 'usd'
        fund_withdrawal.external_id = '1'
        fund_withdrawal.country = 'AR'
        fund_withdrawal.withdrawal_date = DateTime.now.utc
        fund_withdrawal.save!
      end.to change { FundWithdrawal.count }.by(1)
    end

    it "Update a fund deposit with person tags if admin has tags" do
      fund1, fund2, fund3, fund4 = setup_for_admin_tags_spec
      person1 = fund1.person
      person3 = fund3.person

      admin_user.tags << person1.tags.first
      admin_user.save!

      fund_withdrawal = FundWithdrawal.find(fund1.id)
      fund_withdrawal.country = 'BR'
      fund_withdrawal.save!

      fund_withdrawal = FundWithdrawal.find(fund2.id)
      fund_withdrawal.country = 'BR'
      fund_withdrawal.save!

      expect { FundWithdrawal.find(fund3.id) }.to raise_error(ActiveRecord::RecordNotFound)

      fund_withdrawal = FundWithdrawal.find(fund4.id)
      fund_withdrawal.country = 'BR'
      fund_withdrawal.save!

      admin_user.tags << person3.tags.first
      admin_user.save!

      fund_withdrawal = FundWithdrawal.find(fund3.id)
      fund_withdrawal.country = 'BR'
      fund_withdrawal.save!
    end

    it "show fund withdrawal with admin user active tags" do
      fund1, fund2, fund3, fund4 = setup_for_admin_tags_spec
      person1 = fund1.person
      person3 = fund3.person

      expect(FundWithdrawal.find(fund1.id)).to_not be_nil
      expect(FundWithdrawal.find(fund2.id)).to_not be_nil
      expect(FundWithdrawal.find(fund3.id)).to_not be_nil
      expect(FundWithdrawal.find(fund4.id)).to_not be_nil

      admin_user.tags << person1.tags.first
      admin_user.save!

      expect(FundWithdrawal.find(fund1.id)).to_not be_nil
      expect(FundWithdrawal.find(fund2.id)).to_not be_nil
      expect { FundWithdrawal.find(fund3.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(FundWithdrawal.find(fund4.id)).to_not be_nil

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      expect { FundWithdrawal.find(fund1.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(FundWithdrawal.find(fund2.id)).to_not be_nil
      expect(FundWithdrawal.find(fund3.id)).to_not be_nil
      expect(FundWithdrawal.find(fund4.id)).to_not be_nil

      admin_user.tags << person1.tags.first
      admin_user.save!

      expect(FundWithdrawal.find(fund1.id)).to_not be_nil
      expect(FundWithdrawal.find(fund2.id)).to_not be_nil
      expect(FundWithdrawal.find(fund3.id)).to_not be_nil
      expect(FundWithdrawal.find(fund4.id)).to_not be_nil
    end

    it "index fund withdrawal with admin user active tags" do
      fund1, fund2, fund3, fund4 = setup_for_admin_tags_spec
      person1 = fund1.person
      person3 = fund3.person

      withdrawals = FundWithdrawal.all
      expect(withdrawals.count).to eq(4)
      expect(withdrawals[0].id).to eq(fund1.id)
      expect(withdrawals[1].id).to eq(fund2.id)
      expect(withdrawals[2].id).to eq(fund3.id)
      expect(withdrawals[3].id).to eq(fund4.id)

      admin_user.tags << person1.tags.first
      admin_user.save!

      withdrawals = FundWithdrawal.all
      expect(withdrawals.count).to eq(3)
      expect(withdrawals[0].id).to eq(fund1.id)
      expect(withdrawals[1].id).to eq(fund2.id)
      expect(withdrawals[2].id).to eq(fund4.id)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      withdrawals = FundWithdrawal.all
      expect(withdrawals.count).to eq(3)
      expect(withdrawals[0].id).to eq(fund2.id)
      expect(withdrawals[1].id).to eq(fund3.id)
      expect(withdrawals[2].id).to eq(fund4.id)

      admin_user.tags << person1.tags.first
      admin_user.save!

      withdrawals = FundWithdrawal.all
      expect(withdrawals.count).to eq(4)
      expect(withdrawals[0].id).to eq(fund1.id)
      expect(withdrawals[1].id).to eq(fund2.id)
      expect(withdrawals[2].id).to eq(fund3.id)
      expect(withdrawals[3].id).to eq(fund4.id)
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
