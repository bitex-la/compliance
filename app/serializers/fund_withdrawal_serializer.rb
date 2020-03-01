class FundWithdrawalSerializer
  include FastJsonapi::ObjectSerializer
  set_type 'fund_withdrawals'

  belongs_to :person, record_type: 'people'
  has_many :attachments, record_type: 'attachments'

  attributes *%i(amount currency_code
             exchange_rate_adjusted_amount country)

  %i(created_at updated_at withdrawal_date).each do |attr|
    attribute attr do |obj|
      obj.send(attr)
    end
  end
end
