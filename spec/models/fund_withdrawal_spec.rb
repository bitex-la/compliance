require 'rails_helper'

RSpec.describe FundWithdrawal, type: :model do
  it_behaves_like 'person_scopable',
    create: ->(person_id){ create(:full_fund_withdrawal, person_id: person_id) }
  next

  let(:person) { create(:empty_person) }

  it 'validates non null fields' do
    invalid = FundWithdrawal.new
    expect(invalid).not_to be_valid
    expect(invalid.errors.keys).to match_array(%i[
      country currency external_id person amount exchange_rate_adjusted_amount withdrawal_date
    ])
  end

  it 'is valid with a person, currency and withdrawal_date' do
    expect(create(:fund_withdrawal, person: person)).to be_valid
  end

  it 'logs creation of fund withdrawals' do
    object = create(:full_fund_withdrawal, person: person)
    assert_logging(object, :create_entity, 1)
  end

  it 'is not valid if withdrawal_date is in the future' do
    object = build(:fund_withdrawal, person: person, withdrawal_date: 1.hour.from_now)
    expect(object).to_not be_valid
    expect(object.errors.messages.keys.first).to eq(:withdrawal_date)
  end

  it 'is not valid if withdrawal_date is nil' do
    object = build(:fund_withdrawal, person: person, withdrawal_date: nil)
    expect(object).to_not be_valid
    expect(object.errors.messages.keys.first).to eq(:withdrawal_date)
  end

  describe "When filter by admin tags" do
    let(:admin_user) { AdminUser.current_admin_user = create(:admin_user) }

    before :each do
      admin_user.tags.clear
      admin_user.save!
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

    it "Update a fund withdrawal with person tags if admin has tags" do
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

      admin_user.tags.delete person3.tags.last

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
      fundings = fund1, fund2, fund3, fund4 = setup_for_admin_tags_spec
      person1 = fund1.person
      person3 = fund3.person

      fundings.each{|f| expect(FundWithdrawal.find(f.id)).to_not be_nil }

      admin_user.tags << person1.tags.first
      admin_user.save!

      expect(FundWithdrawal.find(fund1.id)).to_not be_nil
      expect(FundWithdrawal.find(fund2.id)).to_not be_nil
      admin_user.tags.delete(person3.tags.last)
      expect { FundWithdrawal.find(fund3.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(FundWithdrawal.find(fund4.id)).to_not be_nil

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags.delete(person1.tags.last)
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

      admin_user.tags.delete(person3.tags.last)
      admin_user.tags << person1.tags.first
      admin_user.save!

      withdrawals = FundWithdrawal.all
      expect(withdrawals.count).to eq(3)
      expect(withdrawals[0].id).to eq(fund1.id)
      expect(withdrawals[1].id).to eq(fund2.id)
      expect(withdrawals[2].id).to eq(fund4.id)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags.delete(person1.tags.last)
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

    it 'add country tag and create a new tag' do
      person = create(:empty_person)

      expect do
        create(:full_fund_withdrawal, person: person)
      end.to change { Tag.count }.by(1)

      person.reload
      tag = Tag.last
      expect(tag.name).to eq 'active-in-AR'
      expect(person.tags.first).to eq(tag)
    end

    it 'add country tag to person not creating a new tag' do
      person = create(:empty_person)
      tag_name = 'active-in-AR'
      tag = Tag.create(tag_type: :person, name: tag_name)

      expect do
        create(:full_fund_withdrawal, person: person)
      end.to change { Tag.count }.by(0)

      person.reload
      expect(person.tags.first).to eq(tag)
    end

    it 'not add country tag to person if already exists' do
      person = create(:empty_person)
      tag_name = 'active-in-AR'
      tag = Tag.create(tag_type: :person, name: tag_name)
      person.tags << tag
      person.save!

      expect do
        create(:full_fund_withdrawal, person: person)
      end.to change { PersonTagging.count }.by(0)

      person.reload
      expect(person.tags.count).to eq(1)
    end

    def setup_for_admin_tags_spec
      person1 = create(:full_person_tagging).person
      person2 = create(:empty_person)
      person3 = create(:alt_full_person_tagging).person
      person4 = create(:empty_person)
      person4.tags << person1.tags.first
      person4.tags << person3.tags.first

      fund1 = create(:full_fund_withdrawal, person: person1)
      fund2 = create(:full_fund_withdrawal, person: person2, country: 'CL')
      fund3 = create(:full_fund_withdrawal, person: person3, country: 'ES')
      fund4 = create(:full_fund_withdrawal, person: person4, country: 'US')

      [fund1, fund2, fund3, fund4]
    end
  end
end
