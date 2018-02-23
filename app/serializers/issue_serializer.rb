class IssueSerializer
  include FastJsonapiCandy::Serializer
  build_belongs_to :person
  build_has_one :domicile_seed, :natural_docket_seed, :legal_entity_docket_seed,
    :identification_seed
  build_has_many :relationship_seeds, :allowance_seeds
end
