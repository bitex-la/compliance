FactoryBot.define do
  factory :full_person_tagging, class: PersonTagging do
    association :person, factory: :empty_person
    association :tag, factory: :person_tag
  end

  factory :alt_full_person_tagging, class: PersonTagging do
    association :person, factory: :empty_person
    association :tag, factory: :alt_person_tag
  end

  factory :invalid_type_person_tagging, class: PersonTagging do
    association :person, factory: :empty_person
    association :tag, factory: :issue_tag
  end
end
