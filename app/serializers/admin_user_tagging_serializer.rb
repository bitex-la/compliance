class AdminUserTaggingSerializer
  include FastJsonapiCandy::Serializer

  build_belongs_to :admin_user, :tag

  build_timestamps
end
