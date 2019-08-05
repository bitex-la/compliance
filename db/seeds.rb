unless Rails.env.production?
  AdminUser.create!(
    email: 'admin@example.com',
    password: 'password',
    password_confirmation: 'password',
    api_token: 'my_secure_api_token'
  )

  ############# CREATE SUPPORT ENTITIES #################
  # 1. Observations reasons
  robot_google = ObservationReason.create!(
    subject_en: 'Robot must run an automated Google review',
    body_en: 'Mr. Robot please go to Google and check the customer',
    subject_es: 'Robot debe correr una revisión automatica en Google',
    body_es: 'Mr. Robot por favor vaya a Google y revise al cliente',
    subject_pt: 'O robô deve executar uma revisão automatizada do Google',
    body_pt: 'Mr. Robot, por favor, vá para o Google e verifique o cliente',
    scope: 1
  )

  human_google = ObservationReason.create!(
    subject_en: 'Admin must run a manual Google review',
    body_en: 'Please go to Google and check the customer',
    subject_es: 'Admin debe correr una revisión manual en Google',
    body_es: 'Por favor vaya a Google y haga una revisión manual',
    subject_pt: 'O administrador deve executar uma revisão manual do Google',
    body_pt: 'Por favor, vá para Google e verifique o cliente',
    scope: 2
  )

  robot_worldcheck = ObservationReason.create!(
    subject_en: 'Robot must run an automated worldcheck review',
    body_en: 'Mr. Robot please go to worldcheck and check the customer',
    subject_es: 'Robot debe correr una revisión automatica en worldcheck',
    body_es: 'Mr. Robot por favor vaya a worldcheck y revise al cliente',
    subject_pt: 'O robô deve executar uma revisão automatizada do worldcheck',
    body_pt: 'Mr. Robot, por favor, vá para o Worldcheck e verifique o cliente',
    scope: 1
  )

  human_worldcheck = ObservationReason.create!(
    subject_en: 'Admin must run a manual worldcheck review',
    body_en: 'Please go to worlcheck and check the customer',
    subject_es: 'Admin debe correr una revisión manual en worldcheck',
    body_es: 'Por favor vaya a worldcheck y haga una revisión manual',
    subject_pt: 'O administrador deve executar uma revisão manual do worldcheck',
    body_pt: 'Por favor, vá para worlcheck e verifique o cliente',
    scope: 2
  )

  risk_score_alert = ObservationReason.create!(
  subject_en: 'Risk score alert',
  body_en: 'New score assessment',
  subject_es: 'Alerta de score de riesgo',
  body_es: 'Nuevo score de riesgo',
  subject_pt: 'Alerta de pontuação de risco',
  body_pt: 'Nova avaliação de pontuação',
  scope: 2
  )

  ilegible_id = ObservationReason.create!(
    subject_en: 'ID attachement(s) are ilegible',
    body_en: 'Please submit again your ID attachments',
    subject_es: 'Los anexos de la identificación son ilegibles',
    body_es: 'Por favor anexe de nuevo los anexos de la identificación',
    subject_pt: 'O anexo de identificação (s) é ilegível',
    body_pt: 'Por favor, envie novamente seus anexos de identificação',
    scope: 0
  )

  incomplete_domicile = ObservationReason.create!(
    subject_en: 'Incomplete domicile(s) info',
    body_en: 'Please complete domicile(s) info',
    subject_es: 'Información de domicilio incompleta',
    body_es: 'Por favor complete la información del domicilio',
    subject_pt: 'Informações incompletas sobre domicílio (s)',
    body_pt: 'Por favor, complete as informações do (s) domicílio (s)',
    scope: 0
  )

  incomplete_basic_info = ObservationReason.create!(
    subject_en: 'Incomplete natural person info',
    body_en: 'Please complete basic info for a natural person',
    subject_es: 'Información de persona natural incompleta',
    body_es: 'Por favor complete la información básica para una persona natural',
    subject_pt: 'Informação de pessoa natural incompleta',
    body_pt: 'Por favor, preencha as informações básicas para uma pessoa natural',
    scope: 0
  )

  incomplete_company_info = ObservationReason.create!(
    subject_en: 'Incomplete legal entity info',
    body_en: 'Please complete basic info for a legal entity',
    subject_es: 'Información de entidad legal incompleta',
    body_es: 'Por favor complete la información básica para una entidad legal',
    subject_pt: 'Informações sobre entidade legal incompleta',
    body_pt: 'Por favor, preencha as informações básicas para uma entidade legal',
    scope: 0
  )

  human_openfactura = ObservationReason.create!(
    subject_en: 'Please check openfactura results',
    body_en: 'Check openfactura review results',
    subject_es: 'Por favor verifica los resultados de openfactura',
    body_es: 'Consulta los resultados de la revisión de openfactura',
    subject_pt: 'O administrador deve executar uma revisão manual do worldcheck',
    body_pt: 'Por favor, verifique os resultados openfactura',
    scope: 2
  )
end
