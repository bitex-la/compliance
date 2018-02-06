FactoryBot.define do
  factory :funding_seed do
    amount 5000.0
    kind   'USD'
    association :issue, factory: :basic_issue
  end  
end