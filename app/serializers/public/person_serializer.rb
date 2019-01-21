class Public::PersonSerializer
  include FastJsonapiCandy::Serializer
  set_type 'people'

  attributes :enabled, :external_id
  attribute :api_token do |object|
    (object.created_at > 10.minutes.ago) ?
      object.api_token :
      ('*' * 20) + object.api_token[-10..-1]
  end
  build_timestamps
  # build_has_many :domiciles, :identifications, :natural_dockets,
  #   :legal_entity_dockets, :allowances, :fund_deposits, :phones, :emails,
  #   :affinities, :risk_scores, :argentina_invoicing_details,
  #   :chile_invoicing_details, :notes, :attachments
end
