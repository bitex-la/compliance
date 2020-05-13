FactoryBot.define do
  factory :basic_issue, class: Issue do
    association :person, factory: :empty_person

    factory :basic_issue_with_tags do
      after(:create) do |issue, evaluator|
        create :full_issue_tagging, issue: issue
      end  
    end

    factory :future_issue do
      defer_until { Date.current + 1.months }
    end
  end

  factory :full_natural_person_issue_with_fixed_email, class: Issue do
    after(:create) do |issue, evaluator|
      %i(
        full_domicile_seed 
        full_risk_score_seed
        full_natural_docket_seed 
        full_natural_person_identification_seed 
        full_argentina_invoicing_detail_seed
        full_phone_seed
        fixed_full_email_seed
        full_note_seed
        full_affinity_seed
        salary_allowance_seed 
        savings_allowance_seed
      ).each do |name|
        create name, issue: issue
      end
    end
  end

  factory :full_natural_person_issue_with_new_client_reason, class: Issue do
    reason { IssueReason.new_client }
    after(:create) do |issue, evaluator|
      %i(
        full_domicile_seed 
        full_risk_score_seed
        full_natural_docket_seed 
        full_natural_person_identification_seed 
        full_argentina_invoicing_detail_seed
        full_phone_seed
        fixed_full_email_seed
        full_note_seed
        full_affinity_seed
        salary_allowance_seed 
        savings_allowance_seed
      ).each do |name|
        create name, issue: issue
      end
    end
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

    factory :new_natural_person_issue do
      association :person, factory: :empty_person
    end

    factory :full_approved_natural_person_issue do
      association :person, factory: :empty_person
      after(:create) do |issue|
        issue.approve!
      end
    end

    
  end

  factory :full_legal_entity_issue, class: Issue do
    after(:create) do |issue, evaluator|
      %i(
        full_domicile_seed 
        full_risk_score_seed
        full_legal_entity_docket_seed 
        full_legal_entity_identification_seed 
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

    factory :new_legal_entity_issue do
      association :person, factory: :empty_person
    end

    factory :full_approved_legal_entity_issue do
      association :person, factory: :empty_person
      after(:create) do |issue|
        issue.approve!
      end
    end
  end
end
