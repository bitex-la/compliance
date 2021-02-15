FactoryBot.define_persons_item_and_seed(:natural_docket,
  full_natural_docket: proc {
    first_name { 'Joe' }
    last_name { 'Doe' }
    birth_date { '2018-01-01' }
    nationality { 'AR' }
    gender_code { 'male' }
    marital_status_code { 'single' }
    job_title { 'Sr. Software developer' }
    job_description { 'Build cool open source software' }
    politically_exposed { false }
    expected_investment { 500.to_d }
    transient{ add_all_attachments { true } }
  },
  alt_full_natural_docket: proc {
    first_name { 'Joel' }
    last_name { 'Doel' }
    birth_date { '2017-01-01' }
    nationality { 'CL' }
    gender_code { 'female' }
    marital_status_code { 'married' }
    job_title { 'Super Sr. Software developer' }
    job_description { 'Build cool open source software software' }
    politically_exposed { true }
    expected_investment { 5000.to_d }
  }
)

FactoryBot.define do 
  factory :strange_natural_docket_seed, class: NaturalDocketSeed do 
    first_name         {'Jáné 微信图片'}
    last_name          {'微信图片 Doçe'}
    birth_date         {'1985-01-01'}
    nationality        {'CO'}
    gender_id          {GenderKind.find(2).id}
    marital_status_id  {MaritalStatusKind.find(1).id}
    job_title          {'Sr. Software Enginéer at 微信'}
    job_description    {'ñáàèçṏ' * 1000}
    politically_exposed {false}
  end
end
