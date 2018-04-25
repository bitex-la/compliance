class EmailSerializer
  include FastJsonapiCandy::Fruit
  attributes :address, :email_kind
  build_timestamps
  derive_seed_serializer!
end
