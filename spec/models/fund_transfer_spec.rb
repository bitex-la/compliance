require 'rails_helper'

describe FundTransfer do
  it_behaves_like 'person_scopable',
    create: -> (person_id) {
      create(:fund_transfer, source_person_id: person_id, target_person: create(:empty_person))
    }
  next

  let(:source_person) { create(:empty_person) }
  let(:target_person) { create(:empty_person) }

  it 'validates non null fields' do
    invalid = FundTransfer.new
    expect(invalid).not_to be_valid
    expect(invalid.errors.keys).to match_array(%i[
      currency source_person target_person amount exchange_rate_adjusted_amount external_id transfer_date
    ])
  end

  it 'is valid with a person, currency and transfer_date' do
    expect(create(:fund_transfer,
                  source_person: source_person,
                  target_person: target_person)
                 ).to be_valid
  end

  it 'logs creation of fund transfers' do
    object = create(:full_fund_transfer,
                    source_person: source_person,
                    target_person: target_person
                   )
    assert_logging(object, :create_entity, 1)
  end

  describe "When filter by admin tags" do
    let(:admin_user) { AdminUser.current_admin_user = create(:admin_user) }

    it "allow fund transfer creation without person tags if admin has no tags" do
      person1 = create(:empty_person)
      person2 = create(:empty_person)

      expect do
        fund = FundTransfer.new(source_person: Person.find(person1.id),
          target_person: Person.find(person2.id))
        fund.amount = 1000
        fund.exchange_rate_adjusted_amount = 1000
        fund.currency_code = 'usd'
        fund.external_id = '1'
        fund.transfer_date = DateTime.now.utc
        fund.save!
      end.to change { FundTransfer.count }.by(1)
    end

    it "allow fund transfer creation without person tags if admin has tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:empty_person)

      admin_user.tags << person1.tags.first
      admin_user.save!

      expect do
        fund = FundTransfer.new(source_person: Person.find(person1.id),
          target_person: Person.find(person2.id))
        fund.amount = 1000
        fund.exchange_rate_adjusted_amount = 1000
        fund.currency_code = 'usd'
        fund.external_id = '1'
        fund.transfer_date = DateTime.now.utc
        fund.save!
      end.to change { FundTransfer.count }.by(1)
    end

    it "Update a fund transfer with person tags if admin has tags" do
      fund_transfer1, fund_transfer2, fund_transfer3, fund_transfer4 = setup_for_admin_tags_spec
      person1 = fund_transfer1.source_person
      person3 = fund_transfer3.source_person

      admin_user.tags << person1.tags.first
      admin_user.save!

      fund_transfer = FundTransfer.find(fund_transfer1.id)
      fund_transfer.amount = '999.98'
      fund_transfer.save!

      fund_transfer = FundTransfer.find(fund_transfer2.id)
      fund_transfer.amount = '999.98'
      fund_transfer.save!

      admin_user.tags.delete person3.tags.last
      expect { FundTransfer.find(fund_transfer3.id) }.to raise_error(ActiveRecord::RecordNotFound)

      fund_transfer = FundTransfer.find(fund_transfer4.id)
      fund_transfer.amount = '999.98'
      fund_transfer.save!

      admin_user.tags << person3.tags.first
      admin_user.save!

      fund_transfer = FundTransfer.find(fund_transfer3.id)
      fund_transfer.amount = '999.98'
      fund_transfer.save!
    end

    it "show fund transfer with admin user active tags" do
      fund_transfer1, fund_transfer2, fund_transfer3, fund_transfer4 = setup_for_admin_tags_spec
      person1 = fund_transfer1.source_person
      person3 = fund_transfer3.source_person

      expect(FundTransfer.find(fund_transfer1.id)).to_not be_nil
      expect(FundTransfer.find(fund_transfer2.id)).to_not be_nil
      expect(FundTransfer.find(fund_transfer3.id)).to_not be_nil
      expect(FundTransfer.find(fund_transfer4.id)).to_not be_nil

      admin_user.tags.delete(person3.tags.last)
      admin_user.tags << person1.tags.first
      admin_user.save!

      expect(FundTransfer.find(fund_transfer1.id)).to_not be_nil
      expect(FundTransfer.find(fund_transfer2.id)).to_not be_nil
      admin_user.tags.delete(person3.tags.last)
      expect { FundTransfer.find(fund_transfer3.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(FundTransfer.find(fund_transfer4.id)).to_not be_nil

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags.delete(person1.tags.last)
      admin_user.tags << person3.tags.first
      admin_user.save!

      expect { FundTransfer.find(fund_transfer1.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(FundTransfer.find(fund_transfer2.id)).to_not be_nil
      expect(FundTransfer.find(fund_transfer3.id)).to_not be_nil
      expect(FundTransfer.find(fund_transfer4.id)).to_not be_nil

      admin_user.tags << person1.tags.first
      admin_user.save!

      expect(FundTransfer.find(fund_transfer1.id)).to_not be_nil
      expect(FundTransfer.find(fund_transfer2.id)).to_not be_nil
      expect(FundTransfer.find(fund_transfer3.id)).to_not be_nil
      expect(FundTransfer.find(fund_transfer4.id)).to_not be_nil
    end

    it "index fund transfer with admin user active tags" do
      fund_transfer1, fund_transfer2, fund_transfer3, fund_transfer4 = setup_for_admin_tags_spec
      person1 = fund_transfer1.source_person
      person3 = fund_transfer3.source_person

      fund_tranfers = FundTransfer.all
      expect(fund_tranfers.count).to eq(4)
      expect(fund_tranfers[0].id).to eq(fund_transfer1.id)
      expect(fund_tranfers[1].id).to eq(fund_transfer2.id)
      expect(fund_tranfers[2].id).to eq(fund_transfer3.id)
      expect(fund_tranfers[3].id).to eq(fund_transfer4.id)

      admin_user.tags.delete(person3.tags.last)
      admin_user.tags << person1.tags.first
      admin_user.save!

      fund_tranfers = FundTransfer.all
      expect(fund_tranfers.count).to eq(3)
      expect(fund_tranfers[0].id).to eq(fund_transfer1.id)
      expect(fund_tranfers[1].id).to eq(fund_transfer2.id)
      expect(fund_tranfers[2].id).to eq(fund_transfer4.id)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags.delete(person1.tags.last)
      admin_user.tags << person3.tags.first
      admin_user.save!

      fund_tranfers = FundTransfer.all
      expect(fund_tranfers.count).to eq(3)
      expect(fund_tranfers[0].id).to eq(fund_transfer2.id)
      expect(fund_tranfers[1].id).to eq(fund_transfer3.id)
      expect(fund_tranfers[2].id).to eq(fund_transfer4.id)

      admin_user.tags << person1.tags.first
      admin_user.save!

      fund_tranfers = FundTransfer.all
      expect(fund_tranfers.count).to eq(4)
      expect(fund_tranfers[0].id).to eq(fund_transfer1.id)
      expect(fund_tranfers[1].id).to eq(fund_transfer2.id)
      expect(fund_tranfers[2].id).to eq(fund_transfer3.id)
      expect(fund_tranfers[3].id).to eq(fund_transfer4.id)
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
