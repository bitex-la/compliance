class EmailSerializer
  include FastJsonapiCandy::Fruit
  attributes :address, :kind
  derive_seed_serializer!
end
