FactoryBot.define do
  factory :identification do
    issue nil
    association :person, factory: :empty_person
  end
end
