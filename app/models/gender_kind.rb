class GenderKind
  include StaticModels::Model
 
  static_models_sparse [
    [1, :female],
    [2, :male],
    [3, :none] 
  ]

  def name
    code
  end
end
