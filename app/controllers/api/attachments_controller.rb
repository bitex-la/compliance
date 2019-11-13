class Api::AttachmentsController < Api::EntityController
  def resource_class
    Attachment
  end

  def options_for_response
    { include: [] }
  end

  protected

  def get_mapper
    can_attach_to = Attachment.attachable_to.map(&:to_sym)

    if params[:data][:attributes][:document_content_type] == 'image/heic'
      file_name = params[:data][:attributes][:document_file_name]
      document, content_type, new_file_name =
        ImageConverter.heic_to_jpg(file_name)

      params[:data][:attributes][:document] = document
      params[:data][:attributes][:document_content_type] = content_type
      params[:data][:attributes][:document_file_name] = new_file_name
    end
    
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      ([:people, :attachments] + can_attach_to),
      can_attach_to.map{|a| [a, []]}.to_h.merge(
        attachments: [
          :document,
          :document_file_name,
          :document_file_size,
          :document_content_type,
          :attached_to_seed,
          :attached_to_fruit,
          :person
        ]
      )
  end
end
