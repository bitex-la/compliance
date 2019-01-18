class Public::PersonSerializer
  include FastJsonapiCandy::Serializer
  set_type 'people'

  attributes :enabled
  build_timestamps
  # build_has_many :domiciles, :identifications, :natural_dockets,
  #   :legal_entity_dockets, :allowances, :fund_deposits, :phones, :emails,
  #   :affinities, :risk_scores, :argentina_invoicing_details,
  #   :chile_invoicing_details, :notes, :attachments
end
