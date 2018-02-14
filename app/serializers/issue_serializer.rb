class IssueSerializer
  include FastJsonapi::ObjectSerializer
  belongs_to :person
  has_many :domicile_seeds
  has_many :identification_seeds
  has_many :natural_docket_seeds
  has_many :legal_entity_docket_seeds
  has_many :relationship_seeds
  has_many :quota_seeds
end