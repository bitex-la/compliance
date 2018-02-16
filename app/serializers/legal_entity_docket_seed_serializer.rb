class LegalEntityDocketSeedSerializer
  include FastJsonapi::ObjectSerializer
  attributes :industry, :business_description, :country, :commercial_name, :legal_name
  belongs_to :issue
  belongs_to :legal_entity_docket
end