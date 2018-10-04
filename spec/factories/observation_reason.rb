FactoryBot.define do
  factory :observation_reason do
    subject_en { "Attachments are not in the ideal resolution" }
    body_en    { "Please add new attachments with a better resolution and quality" }
    subject_es { "Los anexos no estan en la resolución ideal" }
    body_es    { "Por favor añada nuevos archivos con mejor resolución y calidad" }
    subject_pt { "Anexos não estão na resolução ideal" }
    body_pt    { "Por favor, adicione novos anexos com uma melhor resolução e qualidade" }
    scope { 'client' }
  end

  factory :world_check_reason, class: 'ObservationReason' do
    subject_en { "A worldcheck check must be run" }
    body_en { "Run the check!!!!" }
    subject_es { "Se debe correr una revisión en worldcheck" }
    body_es { "Corre el check!!!!" }
    subject_pt { "Uma verificação do worldcheck deve ser executada" }
    body_pt { "Run the check!!!!" }
    scope { 'robot' }
  end

  factory :human_world_check_reason, class: 'ObservationReason' do
    subject_en { "Admin must run a manual worldcheck review" }
    body_en { "Run the check!!" }
    subject_es { "Admin debe correr worldcheck" }
    body_es { "Run the check!!" }
    subject_pt { "Uma verificação do worldcheck deve ser executada" }
    body_pt { "Run the check!!" }
    scope { 'admin' } 
  end

  factory :chainalysis_reason, class: 'ObservationReason' do
    subject_en {"Risk score alert"}
    body_en {"New score assessment"}
    subject_es {"Alerta de score de riesgo"}
    body_es {"Nuevo score de riesgo"}
    subject_pt {"Alerta de pontuação de risco"}
    body_pt {"Nova avaliação de pontuação"}
    scope{ 'admin' }
  end

  factory :incomplete_info_reason, class: 'ObservationReason' do
    subject_en {"Incomplete info"}
    body_en {"Please give us some info"}
    subject_es {"Información incompleta"}
    body_es {"Proveer información extra"}
    subject_pt {"Informação incompleta"}
    body_pt {"Por favor, nos dê algumas informações"}
    scope{ 'client' }
  end
end
