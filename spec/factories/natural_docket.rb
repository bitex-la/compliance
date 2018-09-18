FactoryBot.define_persons_item_and_seed(:natural_docket,
  full_natural_docket: proc {
    first_name        'Joe'
    last_name         'Doe'
    birth_date        '2018-01-01'
    nationality       'AR'
    gender_id          GenderKind.find(1).id
    marital_status_id  MaritalStatusKind.find(1).id
    job_title          'Sr. Software developer'
    job_description    'Build cool open source software'
    politically_exposed false
    transient{ add_all_attachments true }
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
