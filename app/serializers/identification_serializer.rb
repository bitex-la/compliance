class IdentificationSerializer
  include FastJsonapiCandy::PersonThing
  attributes :kind, :number, :issuer
  derive_seed_serializer!
end
