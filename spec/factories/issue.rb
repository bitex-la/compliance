FactoryBot.define do
  factory :basic_issue, class: Issue do
    association :person, factory: :empty_person
  end
end