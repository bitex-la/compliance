class LegalEntityDocketSerializer
  include FastJsonapiCandy::Fruit
  attributes :industry, :business_description, :country, :commercial_name,
    :legal_name
  build_timestamps
  derive_seed_serializer!
end
