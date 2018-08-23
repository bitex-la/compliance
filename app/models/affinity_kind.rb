class AffinityKind
  include StaticModels::Model

  static_models_sparse [
    [10, :spouse],
    [15, :business_partner],
    [20, :couple],
    [25, :manager],
    [30, :owner],
    [35, :immediate_family],
    [40, :extended_family],
    [45, :customer],
    [50, :other],
  ]

  def name
    code
  end
end
