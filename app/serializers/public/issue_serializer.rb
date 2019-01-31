class Public::IssueSerializer
  include FastJsonapiCandy::Serializer
  set_type 'issues'
 
  build_timestamps

  build_belongs_to :person
  
  build_has_one :natural_docket_seed, :legal_entity_docket_seed, 
    :argentina_invoicing_detail_seed, :chile_invoicing_detail_seed

  build_has_many :allowance_seeds, :domicile_seeds, :identification_seeds,
  :phone_seeds, :email_seeds, :affinity_seeds

  has_many :public_note_seeds, key: :note_seeds,
    serializer: 'Public::NoteSeedSerializer', record_type: 'note_seeds'
  has_many :public_observations, key: :observations,
    serializer: 'Public::ObservationSerializer', record_type: 'observations'

  attributes :state
end
