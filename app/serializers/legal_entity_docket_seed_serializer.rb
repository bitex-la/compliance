class LegalEntityDocketSeedsSerializer
  include FastJsonapi::ObjectSerializer
  set_type :legal_entity_docket_seeds
  attributes :industry, :business_description, :country, :commercial_name, :legal_name
  belongs_to :issue
  belongs_to :legal_entity_docket
end