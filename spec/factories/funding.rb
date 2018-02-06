FactoryBot.define do
  factory :funding do
    association :person, factory: :empty_person
    issue nil
  end
end
