class ObservationSerializer
  include FastJsonapiCandy::Serializer
  set_type 'observations'
  build_belongs_to :issue
  build_belongs_to :observation_reason
  attributes *%i(note reply state scope)
end
