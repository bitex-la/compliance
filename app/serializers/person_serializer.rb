class PersonSerializer
  include FastJsonapiCandy::Serializer
  attributes :enabled, :risk
  build_has_many :issues, :domiciles, :identifications, :natural_dockets,
    :legal_entity_dockets, :allowances
end
