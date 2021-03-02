class LegalEntityDocketSerializer
  include FastJsonapiCandy::Fruit
  attributes :industry, :business_description, :country, :commercial_name,
             :legal_name, :regulated_entity, :operations_with_third_party_funds
  build_timestamps
  derive_seed_serializer!
end
