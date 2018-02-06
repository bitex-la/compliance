FactoryBot.define do
  factory :legal_entity_docket do
    issue nil
    association :person, factory: :empty_person
  end
end
