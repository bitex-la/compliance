FactoryBot.define do
  factory :allowance do
    association :person, factory: :empty_person
    issue nil
  end
end
