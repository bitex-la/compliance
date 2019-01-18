class AllowanceSerializer
  include FastJsonapiCandy::Fruit
  attributes :weight, :amount, :kind_code
  build_timestamps
  derive_seed_serializer!
  derive_public_seed_serializer!(:amount, :weight)
end
