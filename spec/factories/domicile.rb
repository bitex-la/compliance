FactoryBot.define do
  factory :domicile do
    association :person, factory: :empty_person
    issue nil
  end
end