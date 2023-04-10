require 'rails_helper'

describe RiskMatrix do
  before :each do
    @natural_person = create(:empty_person)
    @natural_person_issue = create(:basic_issue, person: @natural_person)
    @legal_entity = create(:full_legal_entity_person)
    @legal_entity_issue = create(:basic_issue, person: @legal_entity)
  end

  it 'Risk matrix natural_person HIGH' do
    NaturalDocket.create(person_id: @natural_person.id, issue_id: @natural_person_issue.id, nationality: 'AR', job_title: '202312 - Fabricación de jabones y detergentes', politically_exposed: true)
    Domicile.create(person_id: @natural_person.id, issue_id: @natural_person_issue.id, country: 'AR', state: 'Córdoba', city: 'Córdoba', street_address: 'Bv San Juan', street_number: '373' )
    FundWithdrawal.create(person_id: @natural_person.id, amount: 100, currency_id: 5, country: 'AR', exchange_rate_adjusted_amount: 20, withdrawal_date: Time.now, external_id: 'CashWithdrawal_1')
    FundDeposit.create(person_id: @natural_person.id, amount: 200, currency_id: 5, country: 'AR', exchange_rate_adjusted_amount: 40, deposit_date: Time.now, external_id: 'CashDeposit_1', deposit_method_id: 1)
    RiskScore.create(person_id: @natural_person.id, issue_id: @natural_person_issue.id, provider: 'google')
    RiskScore.create(person_id: @natural_person.id, issue_id: @natural_person_issue.id, provider: 'worldcheck')
    @natural_person.reload

    risk_matrix = RiskMatrix.new(@natural_person)
    expect(risk_matrix.person.id).to eq(1)
    expect(risk_matrix.nationality).to eq('(29) - Argentina')
    expect(risk_matrix.residence).to eq('(20) - Córdoba, Bv San Juan 373')
    expect(risk_matrix.product).to eq('(20) - Operó')
    expect(risk_matrix.transaction_value).to eq('(20) - $300.0')
    expect(risk_matrix.activity).to eq('(60) - 202312 - Fabricación de jabones y detergentes')
    expect(risk_matrix.politically_exposed).to eq('(60) - SI')
    expect(risk_matrix.person_type).to eq('(5) - natural_person')
    expect(risk_matrix.income_means).to eq('(5) - Transferencia bancaria')
    expect(risk_matrix.comercial_history).to eq('(15) - Negativo')
    expect(risk_matrix.result).to eq('(234) - HIGH')
  end

  it 'Risk matrix natural_person MEDIUM' do
    NaturalDocket.create(person_id: @natural_person.id, issue_id: @natural_person_issue.id, nationality: 'AR', job_title: '13011 - Producción de semillas híbridas de cereales y oleaginosas', politically_exposed: false)
    Domicile.create(person_id: @natural_person.id, issue_id: @natural_person_issue.id, country: 'AR', state: 'Córdoba', city: 'Córdoba', street_address: 'Bv San Juan', street_number: '373' )
    FundWithdrawal.create(person_id: @natural_person.id, amount: 100, currency_id: 5, country: 'AR', exchange_rate_adjusted_amount: 20, withdrawal_date: Time.now, external_id: 'CashWithdrawal_1')
    FundDeposit.create(person_id: @natural_person.id, amount: 200, currency_id: 5, country: 'AR', exchange_rate_adjusted_amount: 40, deposit_date: Time.now, external_id: 'CashDeposit_1', deposit_method_id: 1)
    @natural_person.reload

    risk_matrix = RiskMatrix.new(@natural_person)
    expect(risk_matrix.person.id).to eq(1)
    expect(risk_matrix.nationality).to eq('(29) - Argentina')
    expect(risk_matrix.residence).to eq('(20) - Córdoba, Bv San Juan 373')
    expect(risk_matrix.product).to eq('(20) - Operó')
    expect(risk_matrix.transaction_value).to eq('(20) - $300.0')
    expect(risk_matrix.activity).to eq('(20) - 13011 - Producción de semillas híbridas de cereales y oleaginosas')
    expect(risk_matrix.politically_exposed).to eq('(1) - NO')
    expect(risk_matrix.person_type).to eq('(5) - natural_person')
    expect(risk_matrix.income_means).to eq('(5) - Transferencia bancaria')
    expect(risk_matrix.comercial_history).to eq('(5) - Satisfactorio')
    expect(risk_matrix.result).to eq('(125) - MEDIUM')
  end

  it 'Risk matrix legal_entity MEDIUM' do
    LegalEntityDocket.create(person_id: @legal_entity.id, issue_id: @legal_entity_issue.id, country: 'CL', commercial_name: 'Transbank', legal_name: 'Transbank', regulated_entity: false)
    FundWithdrawal.create(person_id: @legal_entity.id, amount: 200, currency_id: 5, country: 'AR', exchange_rate_adjusted_amount: 20, withdrawal_date: Time.now, external_id: 'CashWithdrawal_1')
    FundDeposit.create(person_id: @legal_entity.id, amount: 200, currency_id: 5, country: 'AR', exchange_rate_adjusted_amount: 40, deposit_date: Time.now, external_id: 'CashDeposit_1', deposit_method_id: 1)
    @legal_entity.reload

    risk_matrix = RiskMatrix.new(@legal_entity)
    expect(risk_matrix.person.id).to eq(@legal_entity.id)
    expect(risk_matrix.nationality).to eq('(11) - Chile')
    expect(risk_matrix.residence).to eq('(31) - C.A.B.A, Cullen 5229')
    expect(risk_matrix.product).to eq('(20) - Operó')
    expect(risk_matrix.transaction_value).to eq('(20) - $400.0')
    expect(risk_matrix.activity).to eq('(40) - ')
    expect(risk_matrix.politically_exposed).to eq('(0) - NO')
    expect(risk_matrix.person_type).to eq('(12) - legal_entity')
    expect(risk_matrix.income_means).to eq('(5) - Transferencia bancaria')
    expect(risk_matrix.comercial_history).to eq('(5) - Satisfactorio')
    expect(risk_matrix.result).to eq('(144) - MEDIUM')
  end
end
