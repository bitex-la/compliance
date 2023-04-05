class RiskMatrix < RiskMatrixValue
  attr_reader :person
  
  def initialize(person)
    @person = person
  end
  
  def name
    self.class
  end

  def nationality
    "(#{risk_value_nationality}) - #{risk_value_nationality_desc}"
  end

  def residence
    "(#{risk_value_domicile}) - #{risk_value_domicile_desc}"
  end

  def product
    "(#{risk_value_product}) - #{risk_value_product_desc}"
  end
          
  def transaction_value
    "(#{risk_value_transaction}) - $#{risk_value_transaction_desc}"
  end
          
  def activity
    "(#{risk_value_activity}) - #{risk_value_activity_desc}"
  end

  def politically_exposed
    "(#{risk_value_politically_exposed}) - #{risk_value_politically_exposed_desc}"
  end

  def person_type
    "(#{risk_value_persont_type}) - #{risk_value_persont_type_desc}"
  end

  def income_means
    "(#{risk_value_income_means}) - #{risk_value_income_means_desc}"
  end
          
  def comercial_history
    "(#{risk_value_commercial_history}) - #{risk_value_commercial_history_desc}"
  end

  def result
    value, risk = risk_value_result
    "(#{value}) - #{risk}"
  end

  def created_at
    Time.now.strftime('%d/%m/%Y %H:%M')
  end
end
