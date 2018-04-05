class AttachmentSerializer
  include FastJsonapiCandy::Serializer
  set_type 'attachments'
  attributes :document_file_name, :document_content_type, :document_file_size
  build_belongs_to :person
  build_belongs_to :attached_to_fruit
  build_belongs_to :attached_to_seed
end


