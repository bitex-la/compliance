class DepositMethod
  include StaticModels::Model

  static_models_sparse [
    [1, :bank],
    [2, :debin]
    [3, :btc_tx]
  ]
 
  def name
    code
  end
end
