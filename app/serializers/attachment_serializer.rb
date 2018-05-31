class AttachmentSerializer
  include FastJsonapiCandy::Serializer
  set_type 'attachments'
  attributes :document_file_name, :document_content_type,
    :document_file_size, :document_url

  %i(
    created_at
    updated_at
    document_updated_at
  ).each do |attr|
    attribute attr do |obj|
      obj.send(attr).to_i
    end
  end

  build_belongs_to :person
  belongs_to :attached_to_fruit, polymorphic: true
  belongs_to :attached_to_seed, polymorphic: true
end
