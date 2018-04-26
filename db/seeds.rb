# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
if Rails.env.demo? || Rails.env.development?
=begin
  AdminUser.create!(
    email: 'admin@example.com',
    password: 'password',
    password_confirmation: 'password',
    api_token: 'my_secure_api_token'
 )
=end

 # Argentina full natural person to review
 # 1. Create an empty person
 person = Person.create!(
   enabled: false,
   risk: nil
 )

 # 2. Create an empty issue for the seed data
 issue = Issue.create!(
   person: person
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
      person: person,
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
       person: person,
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
    street_address:  'Cullen',
    street_number: '4356',
    postal_code: '1431',
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
      person: person,
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

  # 14. Add some attachments
  %i(png gif pdf jpg zip).each do |ext|
    Attachment.create!(
      person: person,
      attached_to_seed: ps,
      document: File.new("#{Rails.root}/spec/fixtures/files/simple.#{ext}")
    )
  end

  # 15. Add a note
  NoteSeed.create!(
    title: 'Nickname',
    body: 'Please call me ricky',
    issue: issue
  )
end
