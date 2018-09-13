FactoryBot.define_persons_item_and_seed(:phone,
  full_phone: proc {
    number { '+5491125410470' }
    phone_kind_code { 'main' }
    country { 'AR' }
    has_whatsapp { true }
    has_telegram { false }
    note { 'please do not call on Sundays' }
    transient{ add_all_attachments { true } }
  }, alt_full_phone: proc {
    number { '+5804128632187' }
    phone_kind_code { 'alternative' }
    country { 'VE' }
    has_whatsapp { false }
    has_telegram { true }
    note { 'Call me only on Sundays' }
    transient{ add_all_attachments { false } }
  }
)
