class IssueTokenSerializer
  include FastJsonapiCandy::Serializer

  build_belongs_to :issue
  build_has_many :observations

  attributes :token, :valid_until
end
