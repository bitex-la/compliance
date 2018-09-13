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
  }, 
  alt_full_domicile: proc {
    country { 'VE' }
    state { 'Aragua' }
    city { 'San Mateo' }
    street_address { 'Bolívar' }
    street_number { '123' }
    postal_code { '87322' }
    floor { '1' }
    apartment { 'B' }
    transient{ add_all_attachments { false } }
  }
)
