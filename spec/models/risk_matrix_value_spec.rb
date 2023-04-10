require 'rails_helper'

describe RiskMatrixValue do
  before :each do
    @natural_person = create(:empty_person)
    @natural_person_issue = create(:basic_issue, person: @natural_person)
    @legal_entity = create(:full_legal_entity_person)
    @legal_entity_issue = create(:basic_issue, person: @legal_entity)

    @high_activity = '202312 - Fabricación de jabones y detergentes'
    @low_activity = '13011 - Producción de semillas híbridas de cereales y oleaginosas'
    @natural_contry = 'AR'
    @entity_contry = 'CL'
  end

  it 'Risk matrix value natural_person' do
    NaturalDocket.create(person_id: @natural_person.id, issue_id: @natural_person_issue.id, nationality: @natural_contry, job_title: @high_activity, politically_exposed: true)
    Domicile.create(person_id: @natural_person.id, issue_id: @natural_person_issue.id, country: @natural_contry, state: 'Córdoba', city: 'Córdoba', street_address: 'Bv San Juan', street_number: '373' )
    FundDeposit.create(person_id: @natural_person.id, amount: 200, currency_id: 5, country: @natural_contry, exchange_rate_adjusted_amount: 40, deposit_date: Time.now, external_id: 'CashDeposit_1', deposit_method_id: 1)
    FundWithdrawal.create(person_id: @natural_person.id, amount: 100, currency_id: 5, country: @natural_contry, exchange_rate_adjusted_amount: 20, withdrawal_date: Time.now, external_id: 'CashWithdrawal_1')
    RiskScore.create(person_id: @natural_person.id, issue_id: @natural_person_issue.id, provider: 'google')
    RiskScore.create(person_id: @natural_person.id, issue_id: @natural_person_issue.id, provider: 'worldcheck')
    @natural_person.reload

    risk_matrix_value = RiskMatrix.new(@natural_person)
    expect(risk_matrix_value.person.id).to eq(1)
    expect(risk_matrix_value.risk_value_nationality).to eq(29)
    expect(risk_matrix_value.risk_value_nationality_desc).to eq('Argentina')
    expect(risk_matrix_value.risk_value_domicile).to eq(20)
    expect(risk_matrix_value.risk_value_domicile_desc).to eq('Córdoba, Bv San Juan 373')
    expect(risk_matrix_value.risk_value_product).to eq(20)
    expect(risk_matrix_value.risk_value_product_desc).to eq('Operó')
    expect(risk_matrix_value.risk_value_transaction).to eq(20)
    expect(risk_matrix_value.risk_value_transaction_desc).to eq(300.0)
    expect(risk_matrix_value.risk_value_activity).to eq(60)
    expect(risk_matrix_value.risk_value_activity_desc).to eq(@high_activity)
    expect(risk_matrix_value.risk_value_politically_exposed).to eq(60)
    expect(risk_matrix_value.risk_value_politically_exposed_desc).to eq('SI')
    expect(risk_matrix_value.risk_value_persont_type).to eq(5)
    expect(risk_matrix_value.risk_value_persont_type_desc).to eq(:natural_person)
    expect(risk_matrix_value.risk_value_income_means).to eq(5)
    expect(risk_matrix_value.risk_value_income_means_desc).to eq('Transferencia bancaria')
    expect(risk_matrix_value.risk_value_commercial_history).to eq(15)
    expect(risk_matrix_value.risk_value_commercial_history_desc).to eq('Negativo')
    expect(risk_matrix_value.risk_value_result[0]).to eq(234)
    expect(risk_matrix_value.risk_value_result[1]).to eq('HIGH')
  end

  it 'Risk matrix value natural_person' do
    NaturalDocket.create(person_id: @natural_person.id, issue_id: @natural_person_issue.id, nationality: @natural_contry, job_title: @low_activity, politically_exposed: false)
    Domicile.create(person_id: @natural_person.id, issue_id: @natural_person_issue.id, country: @natural_contry, state: 'Córdoba', city: 'Córdoba', street_address: 'Bv San Juan', street_number: '373' )
    FundWithdrawal.create(person_id: @natural_person.id, amount: 200, currency_id: 5, country: @natural_contry, exchange_rate_adjusted_amount: 20, withdrawal_date: Time.now, external_id: 'CashWithdrawal_1')
    FundDeposit.create(person_id: @natural_person.id, amount: 300, currency_id: 5, country: @natural_contry, exchange_rate_adjusted_amount: 40, deposit_date: Time.now, external_id: 'CashDeposit_1', deposit_method_id: 1)
    
    @natural_person.reload
    risk_matrix_value = RiskMatrix.new(@natural_person)
    expect(risk_matrix_value.person.id).to eq(1)
    expect(risk_matrix_value.risk_value_nationality).to eq(29)
    expect(risk_matrix_value.risk_value_nationality_desc).to eq('Argentina')
    expect(risk_matrix_value.risk_value_domicile).to eq(20)
    expect(risk_matrix_value.risk_value_domicile_desc).to eq('Córdoba, Bv San Juan 373')
    expect(risk_matrix_value.risk_value_product).to eq(20)
    expect(risk_matrix_value.risk_value_product_desc).to eq('Operó')
    expect(risk_matrix_value.risk_value_transaction).to eq(20)
    expect(risk_matrix_value.risk_value_transaction_desc).to eq(500.0)
    expect(risk_matrix_value.risk_value_activity).to eq(20)
    expect(risk_matrix_value.risk_value_activity_desc).to eq(@low_activity)
    expect(risk_matrix_value.risk_value_politically_exposed).to eq(1)
    expect(risk_matrix_value.risk_value_politically_exposed_desc).to eq('NO')
    expect(risk_matrix_value.risk_value_persont_type).to eq(5)
    expect(risk_matrix_value.risk_value_persont_type_desc).to eq(:natural_person)
    expect(risk_matrix_value.risk_value_income_means).to eq(5)
    expect(risk_matrix_value.risk_value_income_means_desc).to eq('Transferencia bancaria')
    expect(risk_matrix_value.risk_value_commercial_history).to eq(5)
    expect(risk_matrix_value.risk_value_commercial_history_desc).to eq('Satisfactorio')
    expect(risk_matrix_value.risk_value_result[0]).to eq(125)
    expect(risk_matrix_value.risk_value_result[1]).to eq('MEDIUM')
  end

  it 'Risk matrix value legal_entity' do
    LegalEntityDocket.create(person_id: @legal_entity.id, issue_id: @legal_entity_issue.id, country: @entity_contry, commercial_name: 'Transbank', legal_name: 'Transbank', regulated_entity: false)
    FundDeposit.create(person_id: @legal_entity.id, amount: 200, currency_id: 5, country: @entity_contry, exchange_rate_adjusted_amount: 40, deposit_date: Time.now, external_id: 'CashDeposit_1', deposit_method_id: 1)
    FundWithdrawal.create(person_id: @legal_entity.id, amount: 200, currency_id: 5, country: @entity_contry, exchange_rate_adjusted_amount: 20, withdrawal_date: Time.now, external_id: 'CashWithdrawal_1')
    
    @legal_entity.reload
    risk_matrix_value = RiskMatrix.new(@legal_entity)
    expect(risk_matrix_value.person.id).to eq(@legal_entity.id)
    expect(risk_matrix_value.risk_value_nationality).to eq(11)
    expect(risk_matrix_value.risk_value_nationality_desc).to eq('Chile')
    expect(risk_matrix_value.risk_value_domicile).to eq(31)
    expect(risk_matrix_value.risk_value_domicile_desc).to eq('C.A.B.A, Cullen 5229')
    expect(risk_matrix_value.risk_value_product).to eq(20)
    expect(risk_matrix_value.risk_value_product_desc).to eq('Operó')
    expect(risk_matrix_value.risk_value_transaction).to eq(20)
    expect(risk_matrix_value.risk_value_transaction_desc).to eq(400.0)
    expect(risk_matrix_value.risk_value_activity).to eq(40)
    expect(risk_matrix_value.risk_value_activity_desc).to eq(nil)
    expect(risk_matrix_value.risk_value_politically_exposed).to eq(0)
    expect(risk_matrix_value.risk_value_politically_exposed_desc).to eq('NO')
    expect(risk_matrix_value.risk_value_persont_type).to eq(12)
    expect(risk_matrix_value.risk_value_persont_type_desc).to eq(:legal_entity)
    expect(risk_matrix_value.risk_value_income_means).to eq(5)
    expect(risk_matrix_value.risk_value_income_means_desc).to eq('Transferencia bancaria')
    expect(risk_matrix_value.risk_value_commercial_history).to eq(5)
    expect(risk_matrix_value.risk_value_commercial_history_desc).to eq('Satisfactorio')
    expect(risk_matrix_value.risk_value_result[0]).to eq(144)
    expect(risk_matrix_value.risk_value_result[1]).to eq('MEDIUM')
  end
end
