class PersonTaggingSerializer
  include FastJsonapiCandy::Serializer

  build_belongs_to :person, :tag

  build_timestamps
end