class LegalEntityDocketSerializer
  include FastJsonapiCandy::PersonThing
  attributes :industry, :business_description, :country, :commercial_name,
    :legal_name
  derive_seed_serializer!
end
