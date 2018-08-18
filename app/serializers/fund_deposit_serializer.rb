class FundDepositSerializer
  include FastJsonapi::ObjectSerializer
  set_type 'fund_deposits'

  belongs_to :person, record_type: 'people'
  has_many :attachments, record_type: 'attachments'

  attributes :amount, :currency_code, :deposit_method_code, :external_id
  
  %i(
    created_at
    updated_at
  ).each do |attr|
    attribute attr do |obj|
      obj.send(attr).to_i
    end
  end
end