class PersonSerializer
  include FastJsonapiCandy::Serializer
  set_type 'people'
  attributes :enabled, :risk 
  build_timestamps
  build_has_many :issues, :domiciles, :identifications, :natural_dockets,
    :legal_entity_dockets, :allowances, :phones, :emails, :affinities,
    :argentina_invoicing_details, :chile_invoicing_details, :notes, :attachments

end
