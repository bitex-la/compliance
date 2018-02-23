class AllowanceSerializer
  include FastJsonapiCandy::PersonThing
  derive_seed_serializer!
  attributes :weight, :amount, :kind
end
