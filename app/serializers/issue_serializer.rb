class IssueSerializer
  include FastJsonapi::ObjectSerializer
  set_type :issues
  belongs_to :person, record_type: :people
  has_one :domicile_seed, record_type: :domicile_seeds
  has_one :identification_seed, record_type: :identification_seeds
  has_one :natural_docket_seed, record_type: :natural_docket_seeds
  has_one :legal_entity_docket_seed, record_type: :legal_entity_docket_seeds
  has_many :relationship_seeds, record_type: :relationship_seeds
  has_many :allowance_seeds, record_type: :allowance_seeds
end
