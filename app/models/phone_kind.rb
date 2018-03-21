class PhoneKind
 include StaticModels::Model
 
 static_models_sparse [
   [1, :main],
   [2, :alternative] 
 ]

 def name
   code
 end
end
