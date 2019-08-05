class PersonSerializer
  include FastJsonapiCandy::Serializer
  set_type 'people'

  attributes :enabled, :risk, :external_id, :person_type, :state
  attribute :api_token do |object|
    (object.created_at > 10.minutes.ago) ?
      object.api_token :
      ('*' * 20) + object.api_token[-10..-1]
  end

  build_belongs_to :regularity

  build_timestamps
  
  build_has_many :issues, :domiciles, :identifications, :natural_dockets,
    :legal_entity_dockets, :allowances, :fund_deposits, :phones, :emails,
    :affinities, :risk_scores, :argentina_invoicing_details,
    :chile_invoicing_details, :notes, :attachments, :tags
end
