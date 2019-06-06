class PersonSerializer
  include FastJsonapiCandy::Serializer
  set_type 'people'

  attributes :enabled, :risk, :person_type

  build_belongs_to :regularity

  build_timestamps
  
  build_has_many :issues, :domiciles, :identifications, :natural_dockets,
    :legal_entity_dockets, :allowances, :fund_deposits, :phones, :emails,
    :affinities, :risk_scores, :argentina_invoicing_details,
    :chile_invoicing_details, :notes, :attachments
end
