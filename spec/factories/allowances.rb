FactoryBot.define_persons_item_and_seed(:allowance,
  salary_allowance: proc {
    weight 1_000
    amount 1_000
    kind "USD"
    after(:create) do |thing|
      %i(jpg png gif pdf zip).each do |name|
        create "#{name}_attachment", attached_to: thing, person: FactoryBot.get_person_from_thing(thing) 
      end
    end
  },
  savings_allowance: proc {
    weight 1_000
    amount 1_000
    kind "USD"
    after(:create) do |thing|
      %i(jpg png gif pdf zip).each do |name|
        create "#{name}_attachment", attached_to: thing, person: FactoryBot.get_person_from_thing(thing) 
      end
    end
  }
)
