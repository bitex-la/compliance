class EmailSerializer
  include FastJsonapiCandy::Fruit
  attributes :address, :email_kind_code
  build_timestamps
  derive_seed_serializer!
end
