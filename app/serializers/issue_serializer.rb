class IssueSerializer
  include FastJsonapi::ObjectSerializer
  belongs_to :person, record_type: :people
  has_one :domicile_seed
  has_one :identification_seed
  has_one :natural_docket_seed
  has_one :legal_entity_docket_seed
  has_many :relationship_seeds
  has_many :quota_seeds
end
