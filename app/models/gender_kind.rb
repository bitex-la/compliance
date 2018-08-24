class GenderKind
  include StaticModels::Model
 
  static_models_sparse [
    [1, :female],
    [2, :male]
  ]

  def name
    code
  end
end
