FactoryBot.define do
  factory :quota_seed do
    weight "9.99"
    amount "9.99"
    kind "USD"
    association :issue, factory: :basic_issue
  end
end
