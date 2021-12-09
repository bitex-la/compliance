class Api::IssueTokensController < Api::ApiController
  before_action :require_token, only: [:show]
  include ApiResponse

  def show
    jsonapi_response IssueToken.find(params[:id])
  end

  def show_by_token
    issue_token = IssueToken.includes(:observations).find_by_token!(params[:issue_token_id])
    jsonapi_response issue_token, include: 'observations'
  rescue IssueTokenNotValidError
    jsonapi_error(410, 'invalid token')
  end

  def reply_observation
    issue_token = IssueToken.includes(:observations).find_by_token!(params[:issue_token_id])
    check_validity_token(params[:issue_token_id], params[:data][:observation][:data][:id]) if issue_token
    params[:data][:attachments] = [] unless params[:data][:attachments]

    map_and_save(200)
  rescue IssueTokenNotValidError
    jsonapi_error(410, 'invalid token')
  end

  protected

  def map_and_save(success_code)
    obs_mapper = observation_mapper
    return jsonapi_422 unless obs_mapper.data

    ActiveRecord::Base.transaction do
      obs_mapper.data.save!
      params[:data][:attachments].each do |attachment|
        attachment_mapper = attachment_mapper(attachment)
        attachment_mapper.data.save!
      end
    end

    jsonapi_response obs_mapper.data, {}, success_code
  rescue ActiveRecord::RecordInvalid => exception
    json_response exception, 422
  end

  def observation_mapper
    observables = Observation.observables.map(&:to_sym)
    JsonapiMapper.doc_unsafe! params[:data][:observation].permit!.to_h,
                              %i[issues observation_reasons observations] + observables,
                              observables.map { |a| [a, []] }.to_h.merge(
                                issues: [],
                                observation_reasons: [],
                                observations: %i[
                                  note
                                  reply
                                  scope
                                  observation_reason
                                  issue
                                  observable
                                ]
                              )
  end

  def attachment_mapper(attachment_params)
    can_attach_to = Attachment.attachable_to.map(&:to_sym)
    JsonapiMapper.doc_unsafe! attachment_params.permit!.to_h,
                              (%i[people attachments] + can_attach_to),
                              can_attach_to.map { |a| [a, []] }.to_h.merge(
                                attachments: %i[
                                  document
                                  document_file_name
                                  document_file_size
                                  document_content_type
                                  attached_to_seed
                                  attached_to_fruit
                                  person
                                ]
                              )
  end

  def check_validity_token(token, observation_id)
    IssueToken
      .includes(:observations)
      .where(observations: { id: observation_id }).find_by_token!(token)
  end
end
