FactoryBot.define_persons_item_and_seed(:phone,
  full_phone: proc {
    number  '+5491125410470'
    kind    'cellphone'
    country 'Argentina'
    has_whatsapp true
    has_telegram false
    note 'please do not call on Sundays'
    transient{ add_all_attachments true }
  }
)
