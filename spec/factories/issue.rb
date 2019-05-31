FactoryBot.define do
  factory :basic_issue, class: Issue do
    association :person, factory: :empty_person
  end

  factory :full_natural_person_issue, class: Issue do
    after(:create) do |issue, evaluator|
      %i(
        full_domicile_seed 
        full_risk_score_seed
        full_natural_docket_seed 
        full_natural_person_identification_seed 
        full_argentina_invoicing_detail_seed
        full_phone_seed
        full_email_seed
        full_note_seed
        full_affinity_seed
        salary_allowance_seed 
        savings_allowance_seed
      ).each do |name|
        create name, issue: issue
      end
    end

    factory :full_approved_natural_person_issue do
      association :person, factory: :empty_person
      after(:create) do |issue|
        issue.approve!
      end
    end

    factory :future_issue do
      association :person, factory: :empty_person
      defer_until { Date.today + 1.months }
    end
  end
end
