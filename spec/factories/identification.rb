FactoryBot.define_persons_item_and_seed(:identification,
  full_natural_person_identification: proc {
    number { '2545566' }
    identification_kind_code { 'national_id' }
    issuer { 'AR' }
    transient{ add_all_attachments { true } }
  }, 
  alt_full_natural_person_identification: proc {
    number { '123456789' }
    identification_kind_code { 'passport' }
    issuer { 'VE' }
    transient{ add_all_attachments { true } }
  }
)
