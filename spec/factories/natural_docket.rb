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
  }
)
