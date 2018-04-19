class EmailKind
 include StaticModels::Model
 
 static_models_sparse [
   [1, :work],
   [2, :personal],
   [3, :invoicing],
   [4, :authentication] 
 ]

 def name
   code
 end
end
