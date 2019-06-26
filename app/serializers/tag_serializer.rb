class TagSerializer
  include FastJsonapiCandy::Serializer

  attributes :name, :tag_type
  build_timestamps
end