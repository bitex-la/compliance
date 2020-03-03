class FundDepositSerializer
  include FastJsonapi::ObjectSerializer
  set_type 'fund_deposits'

  belongs_to :person, record_type: 'people'
  has_many :attachments, record_type: 'attachments'

  attributes *%i(
    amount
    currency_code
    deposit_method_code
    external_id
    exchange_rate_adjusted_amount
    country
    deposit_date
    created_at
    updated_at
  )

end
