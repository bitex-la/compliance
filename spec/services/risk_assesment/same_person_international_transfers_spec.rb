require 'rails_helper'

describe RiskAssesment::SamePersonInternationalTransfers do
  let(:person) { create(:empty_person) }

  it 'creates and approve issue with same_person_international_transfers score' do
    create(:fund_withdrawal, person: person, country: 'AR')
    create(:fund_deposit, person: person, country: 'UY')

    expect do
      RiskAssesment::SamePersonInternationalTransfers.call(person)
    end.to change { Issue.count }.by(1)

    issue = person.reload.issues.last

    expect(issue.approved?).to be true
    expect(issue.risk_score_seeds.count).to be 1
    expect(issue.risk_score_seeds[0].provider).to eq 'open-compliance'
    expect(issue.risk_score_seeds[0].score).to eq 'same_person_international_transfers'

    expect(person.risk_scores.count).to eq 1


    byebug
    # validates deposits and withdrawals sum
  end

  it 'does nothing if transfers are from same country' do

  end

  // escenario en el que hay varios transfer y risk_scores
end
