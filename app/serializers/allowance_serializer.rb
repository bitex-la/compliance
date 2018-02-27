class AllowanceSerializer
  include FastJsonapiCandy::PersonThing
  attributes :weight, :amount, :kind 
  derive_seed_serializer!
end
