class DepositMethod
  include StaticModels::Model

  static_models_sparse [
    [1, :bank],
    [2, :debin]
  ]
 
  def name
    code
  end
end