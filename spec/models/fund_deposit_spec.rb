require 'rails_helper'

RSpec.describe FundDeposit, type: :model do
  let(:person) { create(:empty_person) }

  it 'validates non null fields' do
    invalid = FundDeposit.new
    expect(invalid).not_to be_valid
    expect(invalid.errors.keys).to match_array(%i[
      external_id deposit_method currency person amount
      exchange_rate_adjusted_amount country deposit_date])
  end

  it 'is valid with a person, currency and deposit method' do
    expect(create(:fund_deposit, person: person)).to be_valid
  end

  it 'is not valid if deposit_date is in the future' do
    object = build(:full_fund_deposit, person: person, deposit_date: 1.hour.from_now)
    expect(object).to_not be_valid
    expect(object.errors.messages.keys.first).to eq(:deposit_date)
  end

  it 'is not valid if deposit_date is nil' do
    object = build(:full_fund_deposit, person: person, deposit_date: nil)
    expect(object).to_not be_valid
    expect(object.errors.messages.keys.first).to eq(:deposit_date)
  end

  it 'is valid update a deposit without deposit_date' do
    old_fund_deposit = build(:fund_deposit, deposit_date: nil, person: create(:empty_person))
    old_fund_deposit.save(validate: false)
    old_fund_deposit.update!(amount: 303.00)

    expect(old_fund_deposit).to be_valid

    old_fund_deposit.reload

    expect(old_fund_deposit.amount).to eq(303.00)
  end

  it 'logs creation of fund deposits' do
    object = create(:full_fund_deposit, person: person)
    assert_logging(object, :create_entity, 1)
  end

  describe 'when customer changes regularity' do
    it 'person changes regularity by amount funded' do
      expect(person.regularity).to eq PersonRegularity.none

      create(:alt_fund_deposit, person: person)
      expect(person.regularity).to eq PersonRegularity.none

      expect do
        create(:full_fund_deposit, person: person, amount: 2500)
      end.to change{person.issues.count}.by(1)

      issue = person.issues.last

      expect(issue.risk_score_seeds.last).to have_attributes(
        score: 'low',
        provider: 'open_compliance',
        extra_info_hash: {
          'regularity_funding_amount' => '2500.0',
          'regularity_funding_count' => 3,
          'funding_total_amount' => '3500.0',
          'funding_count' => 2
        }
      )

      expect(issue.reason).to eq(IssueReason.new_risk_information)

      expect(person.regularity).to eq PersonRegularity.low

      assert_logging(person, :update_person_regularity, 1) do |l|
        fund_deposits = l.data.data.relationships.fund_deposits.data
        expect(fund_deposits.size).to eq 2

        expect(l.data.included.find {|x|
          x.type == "regularities" &&
          x.id == PersonRegularity.low.id.to_s
        }).not_to be_nil
      end

      create(:alt_fund_deposit, person: person)
      expect(person.regularity).to eq PersonRegularity.low

      expect do
        create(:full_fund_deposit, person: person, amount: 20000)
      end.to change{person.issues.count}.by(1)

      expect(person.regularity).to eq PersonRegularity.high

      assert_logging(person, :update_person_regularity, 2) do |l|
        fund_deposits = l.data.data.relationships.fund_deposits.data
        expect(fund_deposits.size).to eq 4

        expect(l.data.included.find {|x|
          x.type == "regularities" &&
          x.id == PersonRegularity.high.id.to_s
        }).not_to be_nil
      end

      expect(person.issues.size).to eq 2

      issue = person.issues.last
      expect(issue.risk_score_seeds.last).to have_attributes(
        score: 'high'
      )

      expect(issue.reason).to eq(IssueReason.new_risk_information)
    end

    it 'person changes regularity by funding repeatedly' do
      expect(person.regularity).to eq PersonRegularity.none

      create(:alt_fund_deposit, person: person, amount:1)
      expect(person.regularity).to eq PersonRegularity.none

      create(:full_fund_deposit, person: person, amount:1)
      expect(person.regularity).to eq PersonRegularity.none

      expect do
        create(:alt_fund_deposit, person: person, amount:1)
      end.to change{person.issues.count}.by(1)

      expect(person.regularity).to eq PersonRegularity.low

      assert_logging(person, :update_person_regularity, 1) do |l|
        fund_deposits = l.data.data.relationships.fund_deposits.data
        expect(fund_deposits.size).to eq 3

        expect(l.data.included.find {|x|
          x.type == "regularities" &&
          x.id == PersonRegularity.low.id.to_s
        }).not_to be_nil
      end

      issue = person.issues.last
      expect(issue.risk_score_seeds.last).to have_attributes(
        score: 'low'
      )

      expect(issue.reason).to eq(IssueReason.new_risk_information)

      6.times do
        create(:alt_fund_deposit, person: person, amount:1)
        expect(person.regularity).to eq PersonRegularity.low
      end

      expect do
        create(:full_fund_deposit, person: person, amount: 1)
      end.to change{person.issues.count}.by(1)

      expect(person.regularity).to eq PersonRegularity.high

      assert_logging(person, :update_person_regularity, 2) do |l|
        fund_deposits = l.data.data.relationships.fund_deposits.data
        expect(fund_deposits.size).to eq 10

        expect(l.data.included.find {|x|
          x.type == "regularities" &&
          x.id == PersonRegularity.high.id.to_s
        }).not_to be_nil
      end

      expect(person.issues.size).to eq 2

      issue = person.issues.last
      expect(issue.risk_score_seeds.last).to have_attributes(
        score: 'high'
      )
      expect(issue.reason).to eq(IssueReason.new_risk_information)
    end

    it 'none person can become high_regular by amount funded' do
      expect(person.regularity).to eq PersonRegularity.none

      expect do
        create(:full_fund_deposit, person: person, amount:50000)
      end.to change{person.issues.count}.by(1)

      expect(person.regularity).to eq PersonRegularity.high

      assert_logging(person, :update_person_regularity, 1)

      create(:full_fund_deposit, person: person, amount:50000)
      expect(person.regularity).to eq PersonRegularity.high

      assert_logging(person, :update_person_regularity, 1)

      expect(person.issues.size).to eq 1
    end
  end

  describe "When filter by admin tags" do
    let(:admin_user) { AdminUser.current_admin_user = create(:admin_user) }

    before :each do
      admin_user.tags.clear
      admin_user.save!
    end

    it "allow fund deposit creation only with person valid admin tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:alt_full_person_tagging).person

      admin_user.tags << person1.tags.first
      admin_user.save!

      expect do
        fund_deposit1 = FundDeposit.new(person: Person.find(person1.id))
        fund_deposit1.amount = 1000
        fund_deposit1.exchange_rate_adjusted_amount = 1000
        fund_deposit1.currency_code = 'usd'
        fund_deposit1.deposit_method_code = 'bank'
        fund_deposit1.external_id = '1'
        fund_deposit1.country = 'AR'
        fund_deposit1.deposit_date = DateTime.now.utc
        fund_deposit1.save!
      end.to change { FundDeposit.count }.by(1)

      expect { Person.find(person2.id) }.to raise_error(ActiveRecord::RecordNotFound)

      admin_user.tags << person2.tags.first
      admin_user.save!

      expect do
        fund_deposit1 = FundDeposit.new(person: Person.find(person1.id))
        fund_deposit1.amount = 1000
        fund_deposit1.exchange_rate_adjusted_amount = 1000
        fund_deposit1.currency_code = 'usd'
        fund_deposit1.deposit_method_code = 'bank'
        fund_deposit1.external_id = '1'
        fund_deposit1.country = 'AR'
        fund_deposit1.deposit_date = DateTime.now.utc
        fund_deposit1.save!
      end.to change { FundDeposit.count }.by(1)

      expect do
        fund_deposit1 = FundDeposit.new(person: Person.find(person2.id))
        fund_deposit1.amount = 1000
        fund_deposit1.exchange_rate_adjusted_amount = 1000
        fund_deposit1.currency_code = 'usd'
        fund_deposit1.deposit_method_code = 'bank'
        fund_deposit1.external_id = '1'
        fund_deposit1.country = 'AR'
        fund_deposit1.deposit_date = DateTime.now.utc
        fund_deposit1.save!
      end.to change { FundDeposit.count }.by(1)
    end

    it "allow fund deposit creation with person tags if admin has no tags" do
      person = create(:full_person_tagging).person

      expect do
        fund_deposit1 = FundDeposit.new(person: Person.find(person.id))
        fund_deposit1.amount = 1000
        fund_deposit1.exchange_rate_adjusted_amount = 1000
        fund_deposit1.currency_code = 'usd'
        fund_deposit1.deposit_method_code = 'bank'
        fund_deposit1.external_id = '1'
        fund_deposit1.country = 'AR'
        fund_deposit1.deposit_date = DateTime.now.utc
        fund_deposit1.save!
      end.to change { FundDeposit.count }.by(1)
    end

    it "allow fund deposit creation without person tags if admin has no tags" do
      person = create(:empty_person)

      expect do
        fund_deposit1 = FundDeposit.new(person: Person.find(person.id))
        fund_deposit1.amount = 1000
        fund_deposit1.exchange_rate_adjusted_amount = 1000
        fund_deposit1.currency_code = 'usd'
        fund_deposit1.deposit_method_code = 'bank'
        fund_deposit1.external_id = '1'
        fund_deposit1.country = 'AR'
        fund_deposit1.deposit_date = DateTime.now.utc
        fund_deposit1.save!
      end.to change { FundDeposit.count }.by(1)
    end

    it "allow fund deposit creation without person tags if admin has tags" do
      person1 = create(:full_person_tagging).person

      admin_user.tags << person1.tags.first
      admin_user.save!

      expect do
        fund_deposit1 = FundDeposit.new(person: Person.find(person.id))
        fund_deposit1.amount = 1000
        fund_deposit1.exchange_rate_adjusted_amount = 1000
        fund_deposit1.currency_code = 'usd'
        fund_deposit1.deposit_method_code = 'bank'
        fund_deposit1.external_id = '1'
        fund_deposit1.country = 'AR'
        fund_deposit1.deposit_date = DateTime.now.utc
        fund_deposit1.save!
      end.to change { FundDeposit.count }.by(1)
    end

    it "Update a fund deposit with person tags if admin has tags" do
      fund_deposit1, fund_deposit2, fund_deposit3, fund_deposit4, = setup_for_admin_tags_spec
      person1 = fund_deposit1.person
      person3 = fund_deposit3.person

      admin_user.tags << person1.tags.first
      admin_user.save!

      fund_deposit = FundDeposit.find(fund_deposit1.id)
      fund_deposit.country = 'BR'
      fund_deposit.save!

      fund_deposit = FundDeposit.find(fund_deposit2.id)
      fund_deposit.country = 'BR'
      fund_deposit.save!

      admin_user.tags.delete person3.tags.last
      expect { FundDeposit.find(fund_deposit3.id) }.to raise_error(ActiveRecord::RecordNotFound)

      fund_deposit = FundDeposit.find(fund_deposit4.id)
      fund_deposit.country = 'BR'
      fund_deposit.save!

      admin_user.tags << person3.tags.first
      admin_user.save!

      fund_deposit = FundDeposit.find(fund_deposit3.id)
      fund_deposit.country = 'BR'
      fund_deposit.save!
    end

    it "show fund deposit with admin user active tags" do
      fund_deposit1, fund_deposit2, fund_deposit3, fund_deposit4, = setup_for_admin_tags_spec
      person1 = fund_deposit1.person
      person3 = fund_deposit3.person

      expect(FundDeposit.find(fund_deposit1.id)).to_not be_nil
      expect(FundDeposit.find(fund_deposit2.id)).to_not be_nil
      expect(FundDeposit.find(fund_deposit3.id)).to_not be_nil
      expect(FundDeposit.find(fund_deposit4.id)).to_not be_nil

      admin_user.tags.delete(person3.tags.last)
      admin_user.tags << person1.tags.first
      admin_user.save!

      expect(FundDeposit.find(fund_deposit1.id)).to_not be_nil
      expect(FundDeposit.find(fund_deposit2.id)).to_not be_nil
      admin_user.tags.delete(person3.tags.last)
      expect { FundDeposit.find(fund_deposit3.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(FundDeposit.find(fund_deposit4.id)).to_not be_nil

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags.delete(person1.tags.last)
      admin_user.tags << person3.tags.first
      admin_user.save!

      expect { FundDeposit.find(fund_deposit1.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(FundDeposit.find(fund_deposit2.id)).to_not be_nil
      expect(FundDeposit.find(fund_deposit3.id)).to_not be_nil
      expect(FundDeposit.find(fund_deposit4.id)).to_not be_nil

      admin_user.tags << person1.tags.first
      admin_user.save!

      expect(FundDeposit.find(fund_deposit1.id)).to_not be_nil
      expect(FundDeposit.find(fund_deposit2.id)).to_not be_nil
      expect(FundDeposit.find(fund_deposit3.id)).to_not be_nil
      expect(FundDeposit.find(fund_deposit4.id)).to_not be_nil
    end

    it "index fund deposit with admin user active tags" do
      fund_deposit1, fund_deposit2, fund_deposit3, fund_deposit4, = setup_for_admin_tags_spec
      person1 = fund_deposit1.person
      person3 = fund_deposit3.person

      fund_deposits = FundDeposit.all
      expect(fund_deposits.count).to eq(4)
      expect(fund_deposits[0].id).to eq(fund_deposit1.id)
      expect(fund_deposits[1].id).to eq(fund_deposit2.id)
      expect(fund_deposits[2].id).to eq(fund_deposit3.id)
      expect(fund_deposits[3].id).to eq(fund_deposit4.id)

      admin_user.tags.delete(person3.tags.last)
      admin_user.tags << person1.tags.first
      admin_user.save!

      fund_deposits = FundDeposit.all
      expect(fund_deposits.count).to eq(3)
      expect(fund_deposits[0].id).to eq(fund_deposit1.id)
      expect(fund_deposits[1].id).to eq(fund_deposit2.id)
      expect(fund_deposits[2].id).to eq(fund_deposit4.id)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags.delete(person1.tags.last)
      admin_user.tags << person3.tags.first
      admin_user.save!

      fund_deposits = FundDeposit.all
      expect(fund_deposits.count).to eq(3)
      expect(fund_deposits[0].id).to eq(fund_deposit2.id)
      expect(fund_deposits[1].id).to eq(fund_deposit3.id)
      expect(fund_deposits[2].id).to eq(fund_deposit4.id)

      admin_user.tags << person1.tags.first
      admin_user.save!

      fund_deposits = FundDeposit.all
      expect(fund_deposits.count).to eq(4)
      expect(fund_deposits[0].id).to eq(fund_deposit1.id)
      expect(fund_deposits[1].id).to eq(fund_deposit2.id)
      expect(fund_deposits[2].id).to eq(fund_deposit3.id)
      expect(fund_deposits[3].id).to eq(fund_deposit4.id)
    end

    it 'add country tag and create a new tag' do
      person = create(:empty_person)

      expect do
        create(:full_fund_deposit, person: person)
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
        create(:full_fund_deposit, person: person)
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
        create(:full_fund_deposit, person: person)
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

      fund_deposit1 = create(:full_fund_deposit, person: person1)
      fund_deposit2 = create(:full_fund_deposit, person: person2, country: 'CL')
      fund_deposit3 = create(:full_fund_deposit, person: person3, country: 'ES')
      fund_deposit4 = create(:full_fund_deposit, person: person4, country: 'US')

      [fund_deposit1, fund_deposit2, fund_deposit3, fund_deposit4]
    end
  end
end
