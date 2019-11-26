class VatStatusKind
  include StaticModels::Model
  cattr_accessor :table_name
  
  static_models_sparse [
   [1, :inscripto],
   [2, :consumidor_final],
   [3, :monotributo],
   [4, :exento]
  ]
end
