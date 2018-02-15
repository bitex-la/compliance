FactoryBot.define do
  factory :quota, class: Quotum do
    association :person, factory: :empty_person
    issue nil
  end
end
