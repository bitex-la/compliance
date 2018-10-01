class Api::AttachmentsController < Api::SeedController
  def resource_class
    Attachment
  end

  def options_for_response
    { include: [] }
  end

  protected

  def get_mapper
    can_attach_to = Attachment.attachable_to.map(&:to_sym)
    
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      ([:people, :attachments] + can_attach_to),
      can_attach_to.map{|a| [a, []]}.to_h.merge(
        attachments: [
          :document,
          :document_file_name,
          :document_file_size,
          :document_content_type,
          :attached_to_seed,
          :attached_to_seed_id,
          :attached_to_seed_type,
          :person
        ]
      )
  end
end
