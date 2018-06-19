class ObservationSerializer
  include FastJsonapiCandy::Serializer
  set_type 'observations'
  build_timestamps
  build_belongs_to :issue
  build_belongs_to :observation_reason
  attributes *%i(note reply state scope)
  attribute :subject_en do |object|
    object.observation_reason.subject_en
  end
  attribute :body_en do |object|
    object.observation_reason.body_en
  end
  attribute :subject_es do |object|
    object.observation_reason.subject_es
  end
  attribute :body_es do |object|
    object.observation_reason.body_es
  end
  attribute :subject_pt do |object|
    object.observation_reason.subject_pt
  end
  attribute :body_pt do |object|
    object.observation_reason.body_pt
  end
end
