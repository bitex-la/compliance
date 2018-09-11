FactoryBot.define_persons_item_and_seed(:natural_docket,
  full_natural_docket: proc {
    first_name { 'Joe' }
    last_name { 'Doe' }
    birth_date { '2018-01-01' }
    nationality { 'AR' }
    gender_id { GenderKind.find(1).id }
    marital_status_id { MaritalStatusKind.find(1).id }
    job_title { 'Sr. Software developer' }
    job_description { 'Build cool open source software' }
    politically_exposed { false }
    transient{ add_all_attachments { true } }
  }
)
