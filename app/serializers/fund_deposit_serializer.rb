class FundDepositSerializer
  include FastJsonapiCandy::Fruit
  attributes :amount, :currency_code, :deposit_method_code, :external_id

  build_timestamps
end