FactoryBot.define do
  factory :attachment do
    association :person, factory: :empty_person
  end
end
