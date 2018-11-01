FactoryBot.define_persons_item_and_seed(:identification,
  full_natural_person_identification: proc {
    number { '2545566' }
    identification_kind_code { 'national_id' }
    issuer { 'AR' }
    transient{ add_all_attachments { true } }
  }, 
  full_legal_entity_identification: proc {
    number { '20955794280' }
    identification_kind_code { 'tax_id' }
    issuer { 'AR' }
    public_registry_authority { 'AFIP' }
    public_registry_book { '0001' }
    public_registry_extra_data { '26796' }
    transient{ add_all_attachments { true } }
  },
  alt_full_natural_person_identification: proc {
    number { '123456789' }
    identification_kind_code { 'passport' }
    issuer { 'VE' }
    transient{ add_all_attachments { true } }
  }
)
