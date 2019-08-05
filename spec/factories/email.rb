FactoryBot.define_persons_item_and_seed(:email,
  full_email: proc {
    address { Faker::Internet.email }
    email_kind_code { 'authentication' }
    transient{ add_all_attachments { true } }
  },
  alt_full_email: proc {
    address { Faker::Internet.email }
    email_kind_code { 'invoicing' }
    transient{ add_all_attachments { true } }
  },
  fixed_full_email: proc {
    address { 'admin@example.com' }
    email_kind_code { 'invoicing' }
    transient{ add_all_attachments { true } }
  }
)
