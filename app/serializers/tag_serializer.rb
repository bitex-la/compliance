class TagSerializer
  include FastJsonapiCandy::Serializer
  set_type 'tags'

  attributes :name, :tag_type
  build_timestamps
end
