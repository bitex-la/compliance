class Api::ObservationsController < Api::EntityController
  def resource_class
    Observation
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
        :scope,
        :observation_reason,
        :issue
      ]
  end
end
