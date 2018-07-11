class FundDepositSerializer
  include FastJsonapiCandy::Fruit
  attributes :amount, :currency, :deposit_method

  build_timestamps
  derive_seed_serializer!
end