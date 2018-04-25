class AffinityKind
  include StaticModels::Model

  static_models_sparse [
    [10, :spouse],
    [15, :business_partner],
    [20, :couple],
    [25, :manager]
  ]

  def name
    code
  end
end
