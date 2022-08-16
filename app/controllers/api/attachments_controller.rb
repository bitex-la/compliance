class Api::AttachmentsController < Api::EntityController
  skip_before_action :require_token, only: [:create], if: :issue_token

  def resource_class
    Attachment
  end

  def options_for_response
    { include: [] }
  end

  def create
    if issue_token
      check_validity_token(params[:issue_token_id])
    end

    map_and_save(201)
  rescue IssueTokenNotValidError
    jsonapi_error(410, 'invalid token')
  rescue ActiveRecord::RecordNotFound
    jsonapi_error(404, 'can not find attachment')
  end

  protected

  def related_person
    resource.person_id
  end

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
          :attached_to_fruit,
          :person
        ]
      )
  end

  def check_validity_token(token)
    IssueToken.find_by_token!(token)
  end

  def issue_token
    params[:issue_token_id].present?
  end
end
