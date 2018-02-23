class LegalEntityDocketSerializer
  include FastJsonapiCandy::PersonThing
  derive_seed_serializer!
  attributes :industry, :business_description, :country, :commercial_name,
    :legal_name
end
