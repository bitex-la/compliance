FactoryBot.define do
  factory :basic_issue, class: Issue do
    association :person, factory: :empty_person
  end

  factory :full_natural_person_issue, class: Issue do
    %i(domicile natural_docket identification).each do |name|
      association "#{name}_seed", factory: "full_#{name}_seed"
    end

		after(:create) do |issue, evaluator|
			%i(salary_allowance_seed savings_allowance_seed).each do |name|
				create name, issue: issue
			end
		end
  end
end
