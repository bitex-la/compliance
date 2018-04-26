# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
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
   subject: 'Admin must run a manual worldcheck review',
   body: 'Please go to worlcheck and check the customer',
   scope: 2
 )

 robot_worldcheck = ObservationReason.create!(
   subject: 'Robot must run an automated worldcheck review',
   body: 'Mr. Robot please go to worldcheck and check the customer',
   scope: 1
 )

 ilegible_id = ObservationReason.create!(
   subject: 'ID attachement(s) are ilegible',
   body: 'Please submit again your ID attachments',
   scope: 0
 )

 incomplete_domicile = ObservationReason.create!(
   subject: 'Incomplete domicile(s) info',
   body: 'Please complete domicile(s) info',
   scope: 0
 )

 incomplete_basic_info = ObservationReason.create!(
   subject: 'Incomplete natural person info',
   body: 'Please complete basic info for a natural person',
   scope: 0
 )

 incomplete_company_info = ObservationReason.create!(
   subject: 'Incomplete legal entity info',
   body: 'Please complete basic info for a legal entity',
   scope: 0
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
   gender: 'male',
   marital_status: 'single',
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
    vat_status:   'monotributo',
    tax_id:       '20655764290',
    tax_id_kind:  'cuit',
    receipt_kind: 'a',
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
     identification_kind: 'national_id',
     number: '65576429',
     issuer: 'AR',
     issue:  issue
   )

   passport = IdentificationSeed.create!(
     identification_kind: 'passport',
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
    phone_kind: 'main',
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
    email_kind: 'personal',
    issue: issue
  )

  EmailSeed.create!(
    address: 'richard@piedpider.io',
    email_kind: 'work',
    issue: issue
  )

  # 15. Add a note
  NoteSeed.create!(
    title: 'Nickname',
    body: 'Please call me ricky',
    issue: issue
  )

  ########## AN ARGENTINE LEGAL ENTITY PERSON TO CHECK ##############

  # 1. Create an empty person
  person = Person.create!(
    enabled: false,
    risk: nil
  )

  # 2. Create an empty issue for the seed data
  issue = Issue.create!(
    person: person
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
       person: person,
       attached_to_seed: ld,
       document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
     )
   end

   # 5. Create an argentina invoicing detail seed
   ad = ArgentinaInvoicingDetailSeed.create!(
     vat_status:   'inscripto',
     tax_id:       '2065437230',
     tax_id_kind:  'cuit',
     receipt_kind: 'a',
     name:         'Pied Piper Enterprises',
     country:      'AR',
     address:      'Cabildo 4532',
     issue: issue
   )

   # 6. Add some attachments
    %i(png gif pdf jpg zip).each do |ext|
      Attachment.create!(
        person: person,
        attached_to_seed: ad,
        document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
      )
    end

    # 7. Create some identification seeds
    ids = IdentificationSeed.create!(
      identification_kind: 'tax_id',
      number: '65576429',
      issuer: 'AR',
      issue:  issue
    )

    passport = IdentificationSeed.create!(
      identification_kind: 'company_registration',
      number: 'AR67894532',
      issuer: 'AR',
      issue:  issue
    )

    # 8. Add some attachments
     %i(png gif pdf jpg zip).each do |ext|
       Attachment.create!(
         person: person,
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
        person: person,
        attached_to_seed: ds,
        document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
      )
    end

   # 11. Add a phone seed
   ps = PhoneSeed.create!(
     number: '01800456789',
     phone_kind: 'main',
     country: 'AR',
     note: 'Solo en dias hábiles!!!',
     has_whatsapp: false,
     has_telegram: false,
     issue: issue
   )

   PhoneSeed.create!(
     number: '1125678932',
     phone_kind: 'alternative',
     country: 'AR',
     note: 'Telefono personal CEO',
     has_whatsapp: false,
     has_telegram: false,
     issue: issue
   )

   # 12. Add some attachments
   %i(png gif pdf jpg zip).each do |ext|
     Attachment.create!(
       person: person,
       attached_to_seed: ps,
       document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
     )
   end

   # 13. Add some email seeds
   es = EmailSeed.create!(
     address: 'info@piedpiper.io',
     email_kind: 'work',
     issue: issue
   )

   EmailSeed.create!(
     address: 'invoicing@piedpider.io',
     email_kind: 'invoicing',
     issue: issue
   )

   # 14. Richard Hendricks as Pied Piper manager
   afs = AffinitySeed.create!(
     related_person: richard_hendricks,
     affinity_kind: 'manager',
     issue: issue
   )

   %i(png gif pdf jpg zip).each do |ext|
     Attachment.create!(
       person: person,
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
    gender: 'male',
    marital_status: 'single',
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
    identification_kind: 'national_id',
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
end
