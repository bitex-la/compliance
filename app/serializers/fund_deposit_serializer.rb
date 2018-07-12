class FundDepositSerializer
  include FastJsonapiCandy::Fruit
  attributes :amount, :currency, :deposit_method, :external_id

  build_timestamps
  derive_seed_serializer!
end