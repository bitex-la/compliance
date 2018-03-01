class AttachmentSerializer
  include FastJsonapiCandy::Serializer
  set_type 'attachments'
  build_belongs_to :person
end


