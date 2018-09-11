FactoryBot.define_persons_item_and_seed(:email,
  full_email: proc {
    address { 'joe.doe@test.com' }
    email_kind_id { EmailKind.find(1).id }
    transient{ add_all_attachments { true } }
  }
)
