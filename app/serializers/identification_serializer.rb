class IdentificationSerializer
  include FastJsonapiCandy::Fruit
  attributes :kind, :number, :issuer
  derive_seed_serializer!
end
