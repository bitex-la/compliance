class IssueTaggingSerializer
  include FastJsonapiCandy::Serializer

  build_belongs_to :issue, :tag

  build_timestamps
end