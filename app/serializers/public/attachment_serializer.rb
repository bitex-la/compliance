class Public::AttachmentSerializer
  include FastJsonapiCandy::Serializer
  set_type 'attachments'
  attributes :document_file_name, :document_content_type,
    :document_file_size, :document_url, :created_at, :updated_at,
    :document_updated_at

  build_belongs_to :person
  has_one :attached_to_seed, polymorphic: true
end
