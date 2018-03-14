class IssueSerializer
  include FastJsonapiCandy::Serializer
  set_type 'issues'
  build_belongs_to :person
  build_has_one :natural_docket_seed, :legal_entity_docket_seed
  build_has_many :allowance_seeds, :observations, :domicile_seeds,
    :identification_seeds, :phone_seeds, :email_seeds
  attributes :state
end
