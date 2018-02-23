class IdentificationSerializer
  include FastJsonapiCandy::PersonThing
  derive_seed_serializer!
  attributes :kind, :number, :issuer
end
