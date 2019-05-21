class PersonRegularity
  include StaticModels::Model

  static_models_dense [
    [:id,   :code,      :funding_amount,    :funding_count],
    [1,     :none,         0,                     0],
    [2,     :low,       2500,                     3],
    [3,     :high,      10000,                    10]
  ]

  def applies?(sum, count)
    return true if self == self.class.all.first
    sum >= self.funding_amount || count >= self.funding_count
  end
end
