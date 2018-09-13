class RiskScoreSerializer
  include FastJsonapiCandy::Fruit
  attributes :score, :provider, :extra_info, :external_link
  build_timestamps
  derive_seed_serializer!
end