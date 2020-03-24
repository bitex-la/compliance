require 'rails_helper'

describe RiskAssesment::SamePersonInternationalTransfers do
  let(:person) { create(:empty_person) }

  it 'creates and complete issue with same_person_international_transfers score' do
    create(:fund_withdrawal, person: person, country: 'AR')
    create(:fund_deposit, person: person, country: 'UY')

    expect do
      RiskAssesment::SamePersonInternationalTransfers.call(person)
    end.to change { Issue.count }.by(1)

    issue = person.reload.issues.last

    expect(issue.complete).to be true
    expect(issue.risk_score_seeds.count).to be 1
    expect(issue.risk_score_seeds[0].provider).to eq 'open_compliance'
    expect(issue.risk_score_seeds[0].score).to eq 'same_person_international_transfers'

    extra_info = JSON.parse(issue.risk_score_seeds.first.extra_info)

    expect(extra_info.length).to be(5)

    expect(extra_info['fund_withdrawals_count']).to eq person.fund_withdrawals.count
    expect(extra_info['fund_withdrawals_sum']).to eq person.fund_withdrawals.sum(:exchange_rate_adjusted_amount).to_s

    expect(extra_info['fund_deposits_count']).to eq person.fund_deposits.count
    expect(extra_info['fund_deposits_sum']).to eq person.fund_deposits.sum(:exchange_rate_adjusted_amount).to_s

    expect(extra_info['countries']).to match_array(%w[UY AR])  end

  it 'does nothing if deposit and withdrawal are from same country' do
    create(:fund_withdrawal, person: person, country: 'AR')
    create(:fund_deposit, person: person, country: 'AR')

    expect do
      RiskAssesment::SamePersonInternationalTransfers.call(person)
    end.to change { Issue.count }.by(0)
  end

  it 'does nothing if there are only deposits from same country' do
    create(:fund_deposit, person: person, country: 'AR', amount: 1)
    create(:fund_deposit, person: person, country: 'AR', amount: 1)
    create(:fund_deposit, person: person, country: 'AR', amount: 1)

    RiskAssesment::SamePersonInternationalTransfers.call(person)

    expect do
      RiskAssesment::SamePersonInternationalTransfers.call(person)
    end.to change { Issue.count }.by(0)
  end

  it 'does nothing if there are only withdrawals from the same country' do
    create(:fund_withdrawal, person: person, country: 'AR')
    create(:fund_withdrawal, person: person, country: 'AR')
    create(:fund_withdrawal, person: person, country: 'AR')

    expect do
      RiskAssesment::SamePersonInternationalTransfers.call(person)
    end.to change { Issue.count }.by(0)
  end

  it 'creates and complete issue if only deposits from different countries' do
    create(:fund_deposit, person: person, country: 'AR')
    create(:fund_deposit, person: person, country: 'CL')

    expect do
      RiskAssesment::SamePersonInternationalTransfers.call(person)
    end.to change { Issue.count }.by(1)
  end

  describe 'when there is an approved issue in place' do
    before(:each) {
      create(:fund_deposit, person: person, country: 'AR')
      create(:fund_withdrawal, person: person, country: 'UY')
      RiskAssesment::SamePersonInternationalTransfers.call(person)
      issue = person.reload.issues.last
      issue.approve
    }

    it 'does nothing if new deposit is from same country' do
      create(:fund_deposit, person: person, country: 'UY')

      expect do
        RiskAssesment::SamePersonInternationalTransfers.call(person)
      end.to change { Issue.count }.by(0)
    end

    it 'replace risk_score if new deposit is from different country' do
      create(:fund_deposit, person: person, country: 'CL')

      expect do
        RiskAssesment::SamePersonInternationalTransfers.call(person)
      end.to change { Issue.count }.by(1)

      issue = person.reload.issues.last

      expect(issue.risk_score_seeds[0].replaces).to eq person.risk_scores[0]
    end

    it 'does nothing if new withdrawal is from same country' do
      create(:fund_withdrawal, person: person, country: 'UY')

      expect do
        RiskAssesment::SamePersonInternationalTransfers.call(person)
      end.to change { Issue.count }.by(0)
    end

    it 'replace risk_score if new withdrawal is from different country' do
      create(:fund_withdrawal, person: person, country: 'CL')

      expect do
        RiskAssesment::SamePersonInternationalTransfers.call(person)
      end.to change { Issue.count }.by(1)

      issue = person.reload.issues.last

      expect(issue.risk_score_seeds[0].replaces).to eq person.risk_scores[0]
    end
  end
end
