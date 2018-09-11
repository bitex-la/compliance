class Api::AttachmentsController < Api::SeedController
  def resource_class
    Attachments
  end

  def options_for_response
    { include: [] }
  end

  protected

  def get_mapper
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:attachments],
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
  end
end
