class RiskMatrixValue
  attr_reader :person

  def initialize(person)
    @person = person
    @transaction_value_sum = nil
    @commercial_history = nil
  end

  def risk_value_nationality
    nationality_value
  end

  def risk_value_nationality_desc
    ISO3166::Country.find_country_by_alpha2(person_nationality)&.name
  end

  def risk_value_domicile
    domicile_value
  end

  def risk_value_domicile_desc
    "#{domicile&.state}, #{domicile&.name_body}"
  end

  def risk_value_product
    transaction_value_sum > 0 ? 20 : 10
  end

  def risk_value_product_desc
    transaction_value_sum > 0 ? 'Operó' : 'No operó'
  end

  def risk_value_transaction
    return 20 if transaction_value_sum <= 720000
    transaction_value_sum <= 5000000 ? 40 : 60
  end

  def risk_value_transaction_desc
    transaction_value_sum
  end

  def risk_value_activity
    activity_value
  end

  def risk_value_activity_desc
    natural_docket&.job_title
  end

  def risk_value_politically_exposed
    return 0 if @person.person_type == :legal_entity
    natural_docket&.politically_exposed ? 60 : 1
  end

  def risk_value_politically_exposed_desc
    natural_docket&.politically_exposed ? 'SI' : 'NO'
  end

  def risk_value_persont_type
    person_type_value
  end

  def risk_value_persont_type_desc
    @person.person_type
  end

  def risk_value_income_means
    transaction_value_sum > 0 ? 5 : 5
  end

  def risk_value_income_means_desc
    transaction_value_sum > 0 ? 'Transferencia bancaria' : 'No operó' 
  end

  def risk_value_commercial_history 
    commercial_history_count > 0 ? 15 : 5
  end

  def risk_value_commercial_history_desc
    commercial_history_count > 0 ? 'Negativo' : 'Satisfactorio'
  end

  def risk_value_result
    risk_value_sum = residence_value + risk_value_product + risk_value_transaction + risk_value_activity + 
                     risk_value_politically_exposed + risk_value_persont_type + risk_value_income_means + risk_value_commercial_history
    return [risk_value_sum, 'LOW'] if risk_value_sum < 100
    risk_value_sum < 200 ? [risk_value_sum, 'MEDIUM'] : [risk_value_sum, 'HIGH']
  end
  
  private

  def country_code
    'AR'
  end

  def currency_id
    Currency.find_by_code('ars').id
  end

  def natural_docket
    @person.natural_docket
  end

  def legal_entity_docket
    @person.legal_entity_docket
  end
  
  def domicile
    @person.domiciles.last
  end

  def person_nationality
    if @person.person_type == :natural_person
      natural_docket&.nationality
    else 
      legal_entity_docket&.country
    end
  end

  def nationality_value
    RiskNationality.find_by_code(person_nationality)&.risk_value || 0
  end

  def transaction_value_sum
    if @transaction_value_sum.nil?
      params = { person_id: @person.id, currency_id: currency_id }
      @transaction_value_sum = FundWithdrawal.where(params).sum(:amount) + FundDeposit.where(params).sum(:amount)
    end
    @transaction_value_sum
  end

  def domicile_value
    state_code = I18n.transliterate(domicile&.state || '')&.parameterize(separator: '_')
    @domicile_value = RiskArgentinaState.find_by_code(state_code)&.risk_value || 0
  end

  def residence_value
    # TODO: under review
    # return 0 if person_nationality != country_code and domicile&.country != country_code
    # return risk_value_nationality if person_nationality == country_code and domicile&.country != country_code
    risk_value_nationality + risk_value_domicile
  end

  def person_type_value
    return 0 if @person.person_type.nil?
    @person.person_type == :natural_person ? 5 : 12
  end

  def commercial_history_count
    if @commercial_history.nil?
      @commercial_history = RiskScore.where(provider: ['google', 'worldcheck'], person_id: @person.id).count
    end
    @commercial_history
  end

  def activity_value
    return 40 if @person.person_type == :legal_entity
    return 40 unless natural_docket&.job_title
    code = "a#{natural_docket.job_title.split('-')[0]&.strip}"
    RiskActivity.find_by_code(code)&.value || 40
  end
end
