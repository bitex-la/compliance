class RelationshipSerializer
  include FastJsonapiCandy::Fruit
  attributes :kind  
  derive_seed_serializer!
end
