class AllowanceSerializer
  include FastJsonapiCandy::Fruit
  attributes :weight, :amount, :kind
  build_timestamps
  derive_seed_serializer!
end
