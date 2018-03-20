class RelationshipKind
 include StaticModels::Model
 
 static_models_sparse [
   [10, :spouse],
   [15, :business_partner],
   [20, :couple] 
 ]

 def name
   code
 end
end
