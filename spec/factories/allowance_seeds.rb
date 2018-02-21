FactoryBot.define do
  factory :allowance_seed do
    weight 9.99
    amount 9.99
    kind "USD"
    association :issue, factory: :basic_issue
    
    factory :salary_allowance_seed do
      weight 1_000
      amount 1_000
    end

    factory :savings_allowance_seed do
      weight 100_000
      amount 100_000
    end
  end
end
