class AttachmentSerializer
  include FastJsonapiCandy::Serializer
  set_type 'attachments'
  build_belongs_to :person
  build_belongs_to :attached_to_fruit
  build_belongs_to :attached_to_seed
end


