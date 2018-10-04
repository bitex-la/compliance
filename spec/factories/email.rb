FactoryBot.define_persons_item_and_seed(:email,
  full_email: proc {
    address { 'joe.doe@test.com' }
    email_kind_code { 'work' }
    transient{ add_all_attachments { true } }
  },
  alt_full_email: proc {
    address { 'fullanito_de_tal@mimama.es' }
    email_kind_code { 'personal' }
    transient{ add_all_attachments { true } }
  }
)
