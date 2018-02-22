class PersonSerializer
  include FastJsonapi::ObjectSerializer
  set_type :people
  has_many :issues, record_type: :issues
  has_many :domiciles
  has_many :identifications
  has_many :natural_dockets
  has_many :legal_entity_dockets
  has_many :allowances
end
