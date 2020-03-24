class FundTransferSerializer
  include FastJsonapi::ObjectSerializer
  set_type 'fund_transfers'

  belongs_to :person, record_type: 'people'
  has_many :attachments, record_type: 'attachments'

  attributes *%i(amount currency_code source_person_id
             target_person_id exchange_rate_adjusted_amount
             country transfer_date created_at updated_at)
end
