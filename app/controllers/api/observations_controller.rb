class Api::ObservationsController < Api::SeedController
  def resource_class
    Observation
  end

  protected

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
