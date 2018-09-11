FactoryBot.define do
  factory :empty_person, class: Person do
    enabled { false }
  end

  factory :new_natural_person, class: Person do
    enabled { false }
    risk { nil }

    after(:create) do |person, evaluator|
      create :full_natural_person_issue, person: person
    end
  end

  factory :full_natural_person, class: Person do
    enabled { true }
    risk { :medium }

    after(:create) do |person, evaluator|
      # A full natural person should have at least the issue that created it.
      # Here we start with a basic issue for this person, then the full
      # factories inject their seeds into the basic_issue in their after :create
      create :basic_issue, person: person, aasm_state: 'approved'
      %i(
        full_domicile
        full_risk_score
        full_natural_person_identification
        full_natural_docket
        full_argentina_invoicing_detail
        full_phone
        full_email
        full_note
        full_affinity
        full_fund_deposit
        salary_allowance
        savings_allowance
      ).each do |name|
        create name, person: person
      end
    end
  end

  factory :another_person, class: Person do
  end
end
