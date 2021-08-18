class Api::ObservationsController < Api::EntityController
  def resource_class
    Observation.current
  end

  def update
    params[:data][:id] = resource.id
    check_validity_token(params[:issue_token_id], params[:data][:id]) if params[:issue_token_id]

    map_and_save(200)
  rescue NoMethodError
    jsonapi_422
  rescue IssueTokenNotValidError
    jsonapi_error(410, 'invalid token')
  rescue ActiveRecord::RecordNotFound
    jsonapi_error(404, 'can not find observation')
  end

  protected

  def related_person
    resource.issue.person_id
  end

  def get_mapper
    
    observables = Observation.observables.map(&:to_sym)  
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:issues, :observation_reasons, :observations] + observables,
      observables.map{|a| [a, []]}.to_h.merge(
        issues: [],
        observation_reasons: [],
        observations: [
          :note,
          :reply,
          :scope,
          :observation_reason,
          :issue,
          :observable
        ])
  end

  def check_validity_token(token, observation_id)
    IssueToken
      .includes(:observations)
      .where(observations: { id: observation_id }).find_by_token!(token)
  end
end
