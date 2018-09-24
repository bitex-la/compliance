class Api::ObservationReasonsController < Api::SeedController
  def resource_class
    ObservationReason
  end

  protected

  def get_mapper
    JsonapiMapper.doc_unsafe!(params.permit!.to_h,
      %w(observation_reasons),
      { observation_reasons:
        %i(subject_en body_en subject_es body_es subject_pt body_pt scope) }
    )
  end
end
