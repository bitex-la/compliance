FactoryBot.define do
  factory :empty_person, class: Person do
  end

  factory :full_natural_person, class: Person do
		after(:create) do |person, evaluator|
		  create :full_natural_person_issue, person: person
		end
  end

  factory :another_person, class: Person do
  end
end
