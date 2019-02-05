class Api::Public::ObservationsController < Api::Public::EntityController
  def resource_class
    Observation.where(scope: 'client')
  end

  protected

  def get_mapper
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:issues, :observation_reasons, :observations],
      issues: [],
      observation_reasons: [],
      observations: [
        :note,
        :reply,
        :observation_reason,
        :issue,
        scope: 'client'
      ]
  end
end
