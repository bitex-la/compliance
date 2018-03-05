FactoryBot.define_persons_item_and_seed(:domicile,
  full_domicile: proc {
    country         'Argentina'
    state           'Buenos Aires'
    city            'C.A.B.A'
    street_address  'Cullen'
    street_number   '5229'
    postal_code     '1432'
    floor           '5'
    apartment       'A'
    after(:create) do |thing|
      %i(jpg png gif pdf zip).each do |name|
        create "#{name}_attachment", attached_to: thing, person: FactoryBot.get_person_from_thing(thing) 
      end
    end
  }
)
