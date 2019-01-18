class Public::ObservationReasonSerializer
  include FastJsonapiCandy::Serializer
  set_type 'observation_reasons'
  
  attributes *%i(subject_en body_en subject_es body_es subject_pt body_pt scope) 
end
