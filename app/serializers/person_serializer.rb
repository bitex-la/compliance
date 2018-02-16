class PersonSerializer
  include FastJsonapi::ObjectSerializer
  has_many :issues
  has_many :domiciles
  has_many :identifications
  has_many :natural_dockets
  has_many :legal_entity_dockets
  has_many :quotas, class_name: "Quotum"
end