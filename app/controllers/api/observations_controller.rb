class Api::ObservationsController < Api::EntityController
  def resource_class
    Observation
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
end
