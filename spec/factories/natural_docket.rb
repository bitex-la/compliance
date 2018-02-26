FactoryBot.define_persons_item_and_seed(:natural_docket,
  full_natural_docket: proc {
    first_name     'Joe'
    last_name      'Doe'
    birth_date     '2018-02-26'
    nationality    'Argentina'
    gender         'Male'
    marital_status 'Single'
    after(:create) do |thing|
      %i(jpg png gif pdf zip).each do |name|
        create "#{name}_attachment", attached_to: thing
      end
    end
  }
)
