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
    expect(issue.risk_score_seeds[0].provider).to eq 'open-compliance'
    expect(issue.risk_score_seeds[0].score).to eq 'same_person_international_transfers'

    extra_info = JSON.parse(issue.risk_score_seeds.first.extra_info)

    expect(extra_info.length).to be(6)

    expect(extra_info['fund_withdrawals_count']).to eq person.fund_withdrawals.count
    expect(extra_info['fund_withdrawals_sum']).to eq person.fund_withdrawals.sum(:exchange_rate_adjusted_amount).to_s

    expect(extra_info['fund_deposits_count']).to eq person.fund_deposits.count
    expect(extra_info['fund_deposits_sum']).to eq person.fund_deposits.sum(:exchange_rate_adjusted_amount).to_s

    expect(extra_info['fund_deposits_countries']).to eq(['UY'])
    expect(extra_info['fund_withdrawals_countries']).to eq(['AR'])
  end

  it 'does nothing if transfers are from same country' do
    create(:fund_withdrawal, person: person, country: 'AR')
    create(:fund_deposit, person: person, country: 'AR')

    RiskAssesment::SamePersonInternationalTransfers.call(person)

    expect(Issue.count).to eq 0
  end

  it 'does nothing if there are only deposits' do
    create(:fund_deposit, person: person, country: 'AR')

    RiskAssesment::SamePersonInternationalTransfers.call(person)

    expect(Issue.count).to eq 0
  end

  it 'does nothing if there are only withdrawals' do
    create(:fund_withdrawal, person: person, country: 'AR')

    RiskAssesment::SamePersonInternationalTransfers.call(person)

    expect(Issue.count).to eq 0
  end

  it 'creates a new approved issue and sum funds correctly' do
    6.times do
      create(:fund_withdrawal, person: person, country: 'AR')
      create(:fund_deposit, person: person, country: 'UY')
    end

    3.times do
      create(:fund_withdrawal, person: person, country: 'CL')
      create(:fund_deposit, person: person, country: 'CL')
    end

    issue = create(:full_approved_natural_person_issue)

    expect do
      RiskAssesment::SamePersonInternationalTransfers.call(person)
    end.to change { Issue.count }.by(1)

    issue = person.reload.issues.last

    expect(issue.complete).to be true
    expect(issue.risk_score_seeds.count).to be 1
    expect(issue.risk_score_seeds[0].provider).to eq 'open-compliance'
    expect(issue.risk_score_seeds[0].score).to eq 'same_person_international_transfers'

    extra_info = JSON.parse(issue.risk_score_seeds.first.extra_info)
    fund_withdrawals = person.fund_withdrawals.where(country: 'AR')
    fund_deposits = person.fund_deposits.where(country: 'UY')

    expect(extra_info.length).to be(6)

    expect(extra_info['fund_withdrawals_count']).to eq fund_withdrawals.count
    expect(extra_info['fund_withdrawals_sum']).to eq fund_withdrawals.sum(:exchange_rate_adjusted_amount).to_s

    expect(extra_info['fund_deposits_count']).to eq fund_deposits.count
    expect(extra_info['fund_deposits_sum']).to eq fund_deposits.sum(:exchange_rate_adjusted_amount).to_s

    expect(extra_info['fund_deposits_countries']).to eq(['UY'])
    expect(extra_info['fund_withdrawals_countries']).to eq(['AR'])
  end
end
