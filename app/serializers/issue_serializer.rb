class IssueSerializer
  include FastJsonapiCandy::Serializer
  set_type 'issues'
 
  build_timestamps

  build_belongs_to :person
  
  build_has_one :natural_docket_seed, :legal_entity_docket_seed, 
    :argentina_invoicing_detail_seed, :chile_invoicing_detail_seed

  build_has_many :allowance_seeds, :observations, :domicile_seeds,
    :identification_seeds, :phone_seeds, :email_seeds, 
    :note_seeds, :affinity_seeds, :risk_score_seeds, :tags
  
  attributes :state, :defer_until, :reason_code, :locked, :lock_expiration
end
