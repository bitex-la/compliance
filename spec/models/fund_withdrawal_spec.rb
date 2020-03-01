require 'rails_helper'

RSpec.describe FundWithdrawal, type: :model do
  let(:person) { create(:empty_person) }

  it 'validates non null fields' do
    invalid = FundWithdrawal.new
    expect(invalid).not_to be_valid
    expect(invalid.errors.keys).to match_array(%i[
      currency person amount exchange_rate_adjusted_amount withdrawal_date
    ])
  end

  it 'is valid with a person, currency and withdrawal_date' do
    expect(create(:fund_withdrawal, person: person)).to be_valid
  end

  it 'logs creation of fund withdrawals' do
    object = create(:full_fund_withdrawal, person: person)
    assert_logging(object, :create_entity, 1)
  end

  describe 'when customer changes regularity' do
    it 'person changes regularity by amount funded' do
      skip
      expect(person.regularity).to eq PersonRegularity.none

      create(:alt_fund_withdrawal, person: person)
      expect(person.regularity).to eq PersonRegularity.none

      expect do
        create(:full_fund_withdrawal, person: person, amount: 2500)
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
        fund_withdrawals = l.data.data.relationships.fund_withdrawals.data
        expect(fund_withdrawals.size).to eq 2

        expect(l.data.included.find {|x|
          x.type == "regularities" &&
          x.id == PersonRegularity.low.id.to_s
        }).not_to be_nil
      end

      create(:alt_fund_withdrawal, person: person)
      expect(person.regularity).to eq PersonRegularity.low

      expect do
        create(:full_fund_withdrawal, person: person, amount: 20000)
      end.to change{person.issues.count}.by(1)

      expect(person.regularity).to eq PersonRegularity.high

      assert_logging(person, :update_person_regularity, 2) do |l|
        fund_withdrawals = l.data.data.relationships.fund_withdrawals.data
        expect(fund_withdrawals.size).to eq 4

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
      skip
      expect(person.regularity).to eq PersonRegularity.none

      create(:alt_fund_withdrawal, person: person, amount:1)
      expect(person.regularity).to eq PersonRegularity.none

      create(:full_fund_withdrawal, person: person, amount:1)
      expect(person.regularity).to eq PersonRegularity.none

      expect do
        create(:alt_fund_withdrawal, person: person, amount:1)
      end.to change{person.issues.count}.by(1)

      expect(person.regularity).to eq PersonRegularity.low

      assert_logging(person, :update_person_regularity, 1) do |l|
        fund_withdrawals = l.data.data.relationships.fund_withdrawals.data
        expect(fund_withdrawals.size).to eq 3

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
        create(:alt_fund_withdrawal, person: person, amount:1)
        expect(person.regularity).to eq PersonRegularity.low
      end

      expect do
        create(:full_fund_withdrawal, person: person, amount: 1)
      end.to change{person.issues.count}.by(1)

      expect(person.regularity).to eq PersonRegularity.high

      assert_logging(person, :update_person_regularity, 2) do |l|
        fund_withdrawals = l.data.data.relationships.fund_withdrawals.data
        expect(fund_withdrawals.size).to eq 10

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
      skip
      expect(person.regularity).to eq PersonRegularity.none

      expect do
        create(:full_fund_withdrawal, person: person, amount:50000)
      end.to change{person.issues.count}.by(1)

      expect(person.regularity).to eq PersonRegularity.high

      assert_logging(person, :update_person_regularity, 1)

      create(:full_fund_withdrawal, person: person, amount:50000)
      expect(person.regularity).to eq PersonRegularity.high

      assert_logging(person, :update_person_regularity, 1)

      expect(person.issues.size).to eq 1
    end
  end
end
