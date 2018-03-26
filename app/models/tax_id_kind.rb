class TaxIdKind
  include StaticModels::Model

  static_models_sparse [
    [1,  :rut],
    [80, :cuit],
    [86, :cuil],
    [96, :dni],
    [94, :passport]
  ]

  def name
    code
  end
end
