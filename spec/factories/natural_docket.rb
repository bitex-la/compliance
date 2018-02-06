FactoryBot.define do
  factory :natural_docket do
    issue nil
    association :person, factory: :empty_person
  end
end
