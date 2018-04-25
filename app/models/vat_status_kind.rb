class VatStatusKind
  include StaticModels::Model
  
  static_models_sparse [
   [1, :inscripto],
   [2, :consumidor_final],
   [3, :monotributo]
  ]
end
