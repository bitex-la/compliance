class AllowanceSerializer
  include FastJsonapiCandy::Fruit
  attributes :weight, :amount, :kind 
  derive_seed_serializer!
end
