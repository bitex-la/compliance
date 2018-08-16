if Rails.env.demo? || Rails.env.development?

  AdminUser.create!(
    email: 'admin@example.com',
    password: 'password',
    password_confirmation: 'password',
    api_token: 'my_secure_api_token'
 )

 ############# CREATE SUPPORT ENTITIES #################
 # 1. Observations reasons
 human_worldcheck = ObservationReason.create!(
   subject_en: 'Admin must run a manual worldcheck review',
   body_en: 'Please go to worlcheck and check the customer',
   subject_es: 'Admin debe correr una revisión manual en worldcheck',
   body_es: 'Por favor vaya a worldcheck y haga una revisión manual',
   subject_pt: 'O administrador deve executar uma revisão manual do worldcheck',
   body_pt: 'Por favor, vá para worlcheck e verifique o cliente',
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

 risk_score_alert = ObservationReason.create!(
  subject_en: 'Risk score alert',
  body_en: 'New score assessment',
  subject_es: 'Alerta de score de riesgo',
  body_es: 'Nuevo score de riesgo',
  subject_pt: 'Alerta de pontuação de risco',
  body_pt: 'Nova avaliação de pontuação',
  scope: 2
 )

 ############# AN ARGENTINE NATURAL PERSON TO CHECK ##############
 # 1. Create an empty person
 richard_hendricks = Person.create!(
   enabled: false,
   risk: nil
 )

 # 2. Create an empty issue for the seed data
 issue = Issue.create!(
   person: richard_hendricks
 )

 # 3. Create a natural docket seed
 nd = NaturalDocketSeed.create!(
   first_name:  'Richard',
   last_name:   'Hendricks',
   nationality: 'AR',
   gender_code: 'male',
   marital_status_code: 'single',
   job_title: 'CEO',
   job_description: 'CEO at pied piper',
   birth_date: DateTime.now,
   issue: issue
 )

 # 4. Add some attachments
  %i(png gif pdf jpg zip).each do |ext|
    Attachment.create!(
      person: richard_hendricks,
      attached_to_seed: nd,
      document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
    )
  end

  # 5. Create an argentina invoicing detail seed
  ad = ArgentinaInvoicingDetailSeed.create!(
    vat_status_code:   'monotributo',
    tax_id:       '20655764290',
    tax_id_kind_code:  'cuit',
    receipt_kind_code: 'a',
    name:         'Richard Hendricks',
    country:      'AR',
    address:      'Lavalle 456 apto. 5C',
    issue: issue
  )

  # 6. Add some attachments
   %i(png gif pdf jpg zip).each do |ext|
     Attachment.create!(
       person: richard_hendricks,
       attached_to_seed: ad,
       document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
     )
   end

   # 7. Create some identification seeds
   ids = IdentificationSeed.create!(
     identification_kind_code: 'national_id',
     number: '65576429',
     issuer: 'AR',
     issue:  issue
   )

   passport = IdentificationSeed.create!(
     identification_kind_code: 'passport',
     number: 'AQ76543',
     issuer: 'AR',
     issue:  issue
   )

   # 8. Add some attachments
    %i(png gif pdf jpg zip).each do |ext|
      Attachment.create!(
        person: richard_hendricks,
        attached_to_seed: ids,
        document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
      )
    end

  # 9. Add a domicile seed
  ds = DomicileSeed.create!(
    country: 'AR',
    state: 'Buenos Aires',
    city: 'C.A.B.A',
    street_address:  'Cullen',
    street_number: '4356',
    postal_code: '1431',
    issue: issue
  )

  # 10. Add some attachments
   %i(png gif pdf jpg zip).each do |ext|
     Attachment.create!(
       person: richard_hendricks,
       attached_to_seed: ds,
       document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
     )
   end

  # 11. Add a phone seed
  ps = PhoneSeed.create!(
    number: '1125250468',
    phone_kind_code: 'main',
    country: 'AR',
    note: 'Solo en dias hábiles!!!',
    has_whatsapp: false,
    has_telegram: false,
    issue: issue
  )

  # 12. Add some attachments
  %i(png gif pdf jpg zip).each do |ext|
    Attachment.create!(
      person: richard_hendricks,
      attached_to_seed: ps,
      document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
    )
  end

  # 13. Add some email seeds
  es = EmailSeed.create!(
    address: 'therichard@example.com',
    email_kind_code: 'personal',
    issue: issue
  )

  EmailSeed.create!(
    address: 'richard@piedpider.io',
    email_kind_code: 'work',
    issue: issue
  )

  # 15. Add a note
  NoteSeed.create!(
    title: 'Nickname',
    body: 'Please call me ricky',
    issue: issue
  )

  issue.complete!

  ########## AN ARGENTINE LEGAL ENTITY PERSON TO CHECK ##############

  # 1. Create an empty person
  pied_piper = Person.create!(
    enabled: false,
    risk: nil
  )

  # 2. Create an empty issue for the seed data
  issue = Issue.create!(
    person: pied_piper
  )

  # 3. Create a legal entity docket seed
  ld = LegalEntityDocketSeed.create!(
    industry:  'Software',
    business_description: 'To create a new Internet',
    country: 'AR',
    commercial_name: 'Pied Piper',
    legal_name: 'Pied Piper Enterprises',
    issue: issue
  )

  # 4. Add some attachments
   %i(png gif pdf jpg zip).each do |ext|
     Attachment.create!(
       person: pied_piper,
       attached_to_seed: ld,
       document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
     )
   end

   # 5. Create an argentina invoicing detail seed
   ad = ArgentinaInvoicingDetailSeed.create!(
     vat_status_code:   'inscripto',
     tax_id:       '2065437230',
     tax_id_kind_code:  'cuit',
     receipt_kind_code: 'a',
     name:         'Pied Piper Enterprises',
     country:      'AR',
     address:      'Cabildo 4532',
     issue: issue
   )

   # 6. Add some attachments
    %i(png gif pdf jpg zip).each do |ext|
      Attachment.create!(
        person: pied_piper,
        attached_to_seed: ad,
        document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
      )
    end

    # 7. Create some identification seeds
    ids = IdentificationSeed.create!(
      identification_kind_code: 'tax_id',
      number: '65576429',
      issuer: 'AR',
      issue:  issue
    )

    passport = IdentificationSeed.create!(
      identification_kind_code: 'company_registration',
      number: 'AR67894532',
      issuer: 'AR',
      issue:  issue
    )

    # 8. Add some attachments
     %i(png gif pdf jpg zip).each do |ext|
       Attachment.create!(
         person: pied_piper,
         attached_to_seed: ids,
         document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
       )
     end

   # 9. Add a domicile seed
   ds = DomicileSeed.create!(
     country: 'AR',
     state: 'Buenos Aires',
     city: 'C.A.B.A',
     street_address:  'Cabildo',
     street_number: '4532',
     postal_code: '1478',
     issue: issue
   )

   DomicileSeed.create!(
     country: 'AR',
     state: 'Buenos Aires',
     city: 'C.A.B.A',
     street_address:  'Lavalle',
     street_number: '341',
     postal_code: '1456',
     issue: issue
   )

   # 10. Add some attachments
    %i(png gif pdf jpg zip).each do |ext|
      Attachment.create!(
        person: pied_piper,
        attached_to_seed: ds,
        document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
      )
    end

   # 11. Add a phone seed
   ps = PhoneSeed.create!(
     number: '01800456789',
     phone_kind_code: 'main',
     country: 'AR',
     note: 'Solo en dias hábiles!!!',
     has_whatsapp: false,
     has_telegram: false,
     issue: issue
   )

   PhoneSeed.create!(
     number: '1125678932',
     phone_kind_code: 'alternative',
     country: 'AR',
     note: 'Telefono personal CEO',
     has_whatsapp: false,
     has_telegram: false,
     issue: issue
   )

   # 12. Add some attachments
   %i(png gif pdf jpg zip).each do |ext|
     Attachment.create!(
       person: pied_piper,
       attached_to_seed: ps,
       document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
     )
   end

   # 13. Add some email seeds
   es = EmailSeed.create!(
     address: 'info@piedpiper.io',
     email_kind_code: 'work',
     issue: issue
   )

   EmailSeed.create!(
     address: 'invoicing@piedpider.io',
     email_kind_code: 'invoicing',
     issue: issue
   )

   # 14. Richard Hendricks as Pied Piper manager
   afs = AffinitySeed.create!(
     related_person: richard_hendricks,
     affinity_kind_code: 'manager',
     issue: issue
   )

   %i(png gif pdf jpg zip).each do |ext|
     Attachment.create!(
       person: pied_piper,
       attached_to_seed: afs,
       document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
     )
   end

  ########## AN ARGENTINE INCOMPLETE NATURAL PERSON ############
  # 1. Create an empty person
  dinesh_chugtai = Person.create!(
    enabled: false,
    risk: nil
  )

  # 2. Create an empty issue for the seed data
  issue = Issue.create!(
    person: dinesh_chugtai
  )

  # 3. Create a natural docket seed
  nd = NaturalDocketSeed.create!(
    first_name:  'Dinesh',
    last_name:   'Chugtai',
    nationality: 'AR',
    gender_code: 'male',
    marital_status_code: 'single',
    birth_date: DateTime.now,
    issue: issue
  )

  # 4. Add some attachments
  %i(png gif pdf jpg zip).each do |ext|
    Attachment.create!(
      person: dinesh_chugtai,
      attached_to_seed: nd,
      document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
    )
  end

  # 5. Create some identification seeds
  ids = IdentificationSeed.create!(
    identification_kind_code: 'national_id',
    number: '65576429',
    issuer: 'AR',
    issue:  issue
  )

  Observation.create!(
    issue: issue,
    note: 'Basic info is incomplete',
    scope: 0,
    observation_reason: incomplete_domicile
  )

  Observation.create!(
    issue: issue,
    note: 'ID images are ilegible or does not exist',
    scope: 0,
    observation_reason: ilegible_id
  )

  Observation.create!(
    issue: issue,
    note: 'Robot please check this guy',
    scope: 1,
    observation_reason: robot_worldcheck
  )

  ########## AN ARGENTINE APPROVED NATURAL PERSON ############
  # 1. Create an empty person
  bertram_gilfoyle = Person.create!(
    enabled: false,
    risk: nil
  )

  # 2. Create an empty issue for the seed data
  issue = Issue.create!(
    person: bertram_gilfoyle,
    state: 'new'
  )

  # 3. Create a natural docket seed
  nd = NaturalDocketSeed.create!(
    first_name:  'Bertram',
    last_name:   'Gilfoyle',
    nationality: 'CA',
    gender_code: 'male',
    marital_status_code: 'single',
    job_title: 'DevOps leader',
    job_description: 'DevOps leader at pied piper',
    birth_date: DateTime.now,
    issue: issue
  )

  # 4. Add some attachments
   %i(png gif pdf jpg zip).each do |ext|
     Attachment.create!(
       person: bertram_gilfoyle,
       attached_to_seed: nd,
       document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
     )
   end

   # 5. Create an argentina invoicing detail seed
   ad = ArgentinaInvoicingDetailSeed.create!(
     vat_status_code:   'monotributo',
     tax_id:       '20875764290',
     tax_id_kind_code:  'cuil',
     receipt_kind_code: 'a',
     name:         'Bertram Gilfoyle',
     country:      'AR',
     address:      'Lavalle 456 apto. 5C',
     issue: issue
   )

   # 6. Add some attachments
    %i(png gif pdf jpg zip).each do |ext|
      Attachment.create!(
        person: bertram_gilfoyle,
        attached_to_seed: ad,
        document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
      )
    end

    # 7. Create some identification seeds
    ids = IdentificationSeed.create!(
      identification_kind_code: 'national_id',
      number: '87576429',
      issuer: 'AR',
      issue:  issue
    )

    passport = IdentificationSeed.create!(
      identification_kind_code: 'passport',
      number: 'AQ768343',
      issuer: 'CA',
      issue:  issue
    )

    # 8. Add some attachments
     %i(png gif pdf jpg zip).each do |ext|
       Attachment.create!(
         person: bertram_gilfoyle,
         attached_to_seed: ids,
         document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
       )
     end

   # 9. Add a domicile seed
   ds = DomicileSeed.create!(
     country: 'AR',
     state: 'Buenos Aires',
     city: 'C.A.B.A',
     street_address:  'Viamonte',
     street_number: '4756',
     postal_code: '1567',
     issue: issue
   )

   # 10. Add some attachments
    %i(png gif pdf jpg zip).each do |ext|
      Attachment.create!(
        person: bertram_gilfoyle,
        attached_to_seed: ds,
        document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
      )
    end

   # 11. Add a phone seed
   ps = PhoneSeed.create!(
     number: '1125290468',
     phone_kind_code: 'main',
     country: 'AR',
     note: 'Solo en dias hábiles!!!',
     has_whatsapp: false,
     has_telegram: false,
     issue: issue
   )

   # 12. Add some attachments
   %i(png gif pdf jpg zip).each do |ext|
     Attachment.create!(
       person: bertram_gilfoyle,
       attached_to_seed: ps,
       document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
     )
   end

   # 13. Add some email seeds
   es = EmailSeed.create!(
     address: 'gilfoyle@example.com',
     email_kind_code: 'personal',
     issue: issue
   )

   EmailSeed.create!(
     address: 'gilfoyle@piedpider.io',
     email_kind_code: 'work',
     issue: issue
   )

   # 15. Add a note
   NoteSeed.create!(
     title: 'Nickname',
     body: 'Please call me gilfoyle',
     issue: issue
   )

  # 16. Approving Gilfoyle's onboarding
  issue.approve!

  ########## AN APPROVED CEO(NATURAL PERSON) FOR HOOLI ########################
  # 1. Create an empty person
  gavin_belson = Person.create!(
    enabled: false,
    risk: nil
  )

  # 2. Create an empty issue for the seed data
  issue = Issue.create!(
    person: gavin_belson,
    state: 'new'
  )

  # 3. Create a natural docket seed
  nd = NaturalDocketSeed.create!(
    first_name:  'Gavin',
    last_name:   'Belson',
    nationality: 'US',
    gender_code: 'male',
    marital_status_code: 'single',
    job_title: 'CEO',
    job_description: 'CEO at Hooli',
    birth_date: DateTime.now,
    issue: issue
  )

  # 4. Add some attachments
   %i(png gif pdf jpg zip).each do |ext|
     Attachment.create!(
       person: gavin_belson,
       attached_to_seed: nd,
       document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
     )
   end

   # 7. Create some identification seeds
   ids = IdentificationSeed.create!(
     identification_kind_code: 'passport',
     number: 'AQ768332',
     issuer: 'US',
     issue:  issue
   )

   # 8. Add some attachments
    %i(png gif pdf jpg zip).each do |ext|
      Attachment.create!(
        person: gavin_belson,
        attached_to_seed: ids,
        document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
      )
    end

  # 9. Add a domicile seed
  ds = DomicileSeed.create!(
    country: 'US',
    state: 'California',
    city: 'Palo Alto',
    street_address:  'Hooli Street',
    street_number: '34',
    postal_code: '45098',
    issue: issue
  )

  # 10. Add some attachments
   %i(png gif pdf jpg zip).each do |ext|
     Attachment.create!(
       person: gavin_belson,
       attached_to_seed: ds,
       document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
     )
   end

  # 11. Add a phone seed
  ps = PhoneSeed.create!(
    number: '1120290478',
    phone_kind_code: 'main',
    country: 'AR',
    note: 'Solo en dias hábiles!!!',
    has_whatsapp: false,
    has_telegram: false,
    issue: issue
  )

  # 12. Add some attachments
  %i(png gif pdf jpg zip).each do |ext|
    Attachment.create!(
      person: gavin_belson,
      attached_to_seed: ps,
      document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
    )
  end

  # 13. Add some email seeds
  es = EmailSeed.create!(
    address: 'gavin@hooli.com',
    email_kind_code: 'personal',
    issue: issue
  )

  # 14. Approving Gavin's onboarding
  issue.approve!

  ########## AN APPROVED ARGENTINE LEGAL ENTITY  ##############

  # 1. Create an empty person
  hooli = Person.create!(
    enabled: false,
    risk: nil
  )

  # 2. Create an empty issue for the seed data
  issue = Issue.create!(
    person: hooli
  )

  # 3. Create a legal entity docket seed
  ld = LegalEntityDocketSeed.create!(
    industry:  'Software',
    business_description: 'To dominate the world',
    country: 'US',
    commercial_name: 'Hooli',
    legal_name: 'Hooli INC.',
    issue: issue
  )

  # 4. Add some attachments
   %i(png gif pdf jpg zip).each do |ext|
     Attachment.create!(
       person: hooli,
       attached_to_seed: ld,
       document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
     )
   end

   # 5. Create an argentina invoicing detail seed
   ad = ArgentinaInvoicingDetailSeed.create!(
     vat_status_code:   'inscripto',
     tax_id:       '20789056430',
     tax_id_kind_code:  'cuit',
     receipt_kind_code: 'b',
     name:         'Hooli INC',
     country:      'AR',
     address:      'Ayacucho 235',
     issue: issue
   )

   # 6. Add some attachments
    %i(png gif pdf jpg zip).each do |ext|
      Attachment.create!(
        person: hooli,
        attached_to_seed: ad,
        document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
      )
    end

  # 7. Create some identification seeds
  ids = IdentificationSeed.create!(
    identification_kind_code: 'tax_id',
    number: '20789056430',
    issuer: 'AR',
    issue:  issue
  )

  passport = IdentificationSeed.create!(
    identification_kind_code: 'company_registration',
    number: 'AR78905643',
    issuer: 'AR',
    issue:  issue
  )

  # 8. Add some attachments
   %i(png gif pdf jpg zip).each do |ext|
     Attachment.create!(
       person: hooli,
       attached_to_seed: ids,
       document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
     )
   end

  # 9. Add a domicile seed
  ds = DomicileSeed.create!(
   country: 'AR',
   state: 'Buenos Aires',
   city: 'C.A.B.A',
   street_address:  'Ayacucho',
   street_number: '235',
   postal_code: '1467',
   issue: issue
  )

  # 10. Add some attachments
  %i(png gif pdf jpg zip).each do |ext|
    Attachment.create!(
      person: hooli,
      attached_to_seed: ds,
      document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
    )
  end

  # 11. Add a phone seed
  ps = PhoneSeed.create!(
   number: '01800452689',
   phone_kind_code: 'main',
   country: 'AR',
   note: 'Solo en dias hábiles!!!',
   has_whatsapp: false,
   has_telegram: false,
   issue: issue
  )

  # 12. Add some attachments
  %i(png gif pdf jpg zip).each do |ext|
   Attachment.create!(
     person: hooli,
     attached_to_seed: ps,
     document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
   )
  end

  # 13. Add some email seeds
  es = EmailSeed.create!(
    address: 'hello@hooli.com',
    email_kind_code: 'work',
    issue: issue
  )

  EmailSeed.create!(
    address: 'invoicing@hooli.com',
    email_kind_code: 'invoicing',
    issue: issue
  )

  # 14. Gavin Belson as Hooli manager
  afs = AffinitySeed.create!(
    related_person: gavin_belson,
    affinity_kind_code: 'manager',
    issue: issue
  )

  %i(png gif pdf jpg zip).each do |ext|
    Attachment.create!(
      person: hooli,
      attached_to_seed: afs,
      document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
    )
  end

  # 15. Approving Hooli's onboarding as company
  issue.approve!

  ############# AN ARGENTINE NATURAL PERSON WITH SOME REPLIES ##############
  # 1. Create an empty person
  nelson_bighetti = Person.create!(
    enabled: false,
    risk: nil
  )

  # 2. Create an empty issue for the seed data
  issue = Issue.create!(
    person: nelson_bighetti
  )

  # 3. Create a natural docket seed
  nd = NaturalDocketSeed.create!(
    first_name:  'Nelson',
    last_name:   'Bighetti',
    nationality: 'AR',
    gender_code: 'male',
    marital_status_code: 'single',
    job_title: 'Risk Investor',
    job_description: 'Investor at Big Head Inc',
    birth_date: DateTime.now,
    issue: issue
  )

  # 4. Add some attachments
   %i(png gif pdf jpg zip).each do |ext|
     Attachment.create!(
       person: nelson_bighetti,
       attached_to_seed: nd,
       document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
     )
   end

   # 5. Create an argentina invoicing detail seed
   ad = ArgentinaInvoicingDetailSeed.create!(
     vat_status_code:   'monotributo',
     tax_id:       '20955464310',
     tax_id_kind_code:  'cuil',
     receipt_kind_code: 'a',
     name:         'Nelson Bighetti',
     country:      'AR',
     address:      'Federico Lacroze 342 apto 4B',
     issue: issue
   )

   # 6. Add some attachments
    %i(png gif pdf jpg zip).each do |ext|
      Attachment.create!(
        person: nelson_bighetti,
        attached_to_seed: ad,
        document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
      )
    end

    # 7. Create some identification seeds
    ids = IdentificationSeed.create!(
      identification_kind_code: 'national_id',
      number: '95546431',
      issuer: 'AR',
      issue:  issue
    )

    passport = IdentificationSeed.create!(
      identification_kind_code: 'passport',
      number: 'AQ76413',
      issuer: 'US',
      issue:  issue
    )

    # 8. Add some attachments
     %i(png gif pdf jpg zip).each do |ext|
       Attachment.create!(
         person: nelson_bighetti,
         attached_to_seed: ids,
         document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
       )
     end

   # 9. Add a domicile seed
   ds = DomicileSeed.create!(
     country: 'AR',
     state: 'Buenos Aires',
     city: 'C.A.B.A',
     street_address:  'Federico Lacroze',
     street_number: '342',
     floor: '4',
     apartment: 'B',
     postal_code: '1431',
     issue: issue
   )

   # 10. Add some attachments
    %i(png gif pdf jpg zip).each do |ext|
      Attachment.create!(
        person: nelson_bighetti,
        attached_to_seed: ds,
        document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
      )
    end

   # 11. Add a phone seed
   ps = PhoneSeed.create!(
     number: '1165251454',
     phone_kind_code: 'main',
     country: 'AR',
     note: 'Solo en dias hábiles!!!',
     has_whatsapp: false,
     has_telegram: false,
     issue: issue
   )

   # 12. Add some attachments
   %i(png gif pdf jpg zip).each do |ext|
     Attachment.create!(
       person: nelson_bighetti,
       attached_to_seed: ps,
       document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
     )
   end

   # 13. Add some email seeds
   es = EmailSeed.create!(
     address: 'bighead@example.com',
     email_kind_code: 'personal',
     issue: issue
   )

   # 15. Add a note
   NoteSeed.create!(
     title: 'Nickname',
     body: 'Please call me Big Head',
     issue: issue
   )

   issue.complete!

   observation_one =  Observation.create!(
     issue: issue,
     note: 'Basic info is incomplete',
     scope: 0,
     observation_reason: incomplete_domicile
   )

   observation_two = Observation.create!(
     issue: issue,
     note: 'ID images are ilegible or does not exist',
     scope: 0,
     observation_reason: ilegible_id
   )

  observation_one.reply = 'Info completed, please check!'
  observation_two.reply = 'I sent a new photo, please check it ;)'
  observation_one.save
  observation_two.save
end
