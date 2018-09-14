class SimplePersonSerializer
  include FastJsonapiCandy::Serializer
  set_type 'people'

  attributes :enabled, :risk
  build_timestamps
end
