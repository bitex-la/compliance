class FundWithdrawalSerializer
  include FastJsonapi::ObjectSerializer
  set_type 'fund_withdrawals'

  belongs_to :person, record_type: 'people'
  has_many :attachments, record_type: 'attachments'

  attributes *%i(amount currency_code external_id
             exchange_rate_adjusted_amount country
             withdrawal_date created_at updated_at)
end
