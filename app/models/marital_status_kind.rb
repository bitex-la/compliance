class MaritalStatusKind
 include StaticModels::Model
 
 static_models_sparse [
   [1, :single],
   [2, :married],
   [3, :divorced],
   [4, :widowed],
   [5, :none]
 ]

 def name
   code
 end
end
