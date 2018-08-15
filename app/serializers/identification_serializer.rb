class IdentificationSerializer
  include FastJsonapiCandy::Fruit
  attributes :identification_kind_code, :number, :issuer, :public_registry_authority,
    :public_registry_book, :public_registry_extra_data

  build_timestamps
  derive_seed_serializer!
end
