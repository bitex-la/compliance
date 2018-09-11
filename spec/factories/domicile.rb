FactoryBot.define_persons_item_and_seed(:domicile,
  full_domicile: proc {
    country { 'AR' }
    state { 'Buenos Aires' }
    city { 'C.A.B.A' }
    street_address { 'Cullen' }
    street_number { '5229' }
    postal_code { '1432' }
    floor { '5' }
    apartment { 'A' }
    transient{ add_all_attachments { true } }
  }
)
