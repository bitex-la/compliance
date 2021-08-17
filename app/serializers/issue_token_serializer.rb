class IssueTokenSerializer
  include FastJsonapiCandy::Serializer

  build_belongs_to :issue

  attributes :token, :valid_until
end
