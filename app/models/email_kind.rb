class EmailKind
 include StaticModels::Model
 
 static_models_sparse [
   [1, :work],
   [2, :personal] 
 ]

 def name
   code
 end
end
