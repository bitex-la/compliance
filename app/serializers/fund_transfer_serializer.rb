class FundTransferSerializer
  include FastJsonapi::ObjectSerializer
  set_type 'fund_transfers'

  belongs_to :source_person, record_type: 'people', serializer: 'PersonSerializer'
  belongs_to :target_person, record_type: 'people', serializer: 'PersonSerializer'
  has_many :attachments, record_type: 'attachments'

  attributes *%i(amount currency_code exchange_rate_adjusted_amount
             transfer_date external_id created_at updated_at)
end
