FactoryBot.define do
  factory :full_fund_deposit, class: FundDeposit do
    amount { 1000 }
    exchange_rate_adjusted_amount{ amount }
    currency_code { 'usd' }
    deposit_method_code { 'bank' }
    external_id { "1" }
    country { 'AR' }
    deposit_date { DateTime.now.utc }
  end

  factory :fund_deposit, class: FundDeposit do
    amount { 1000 }
    exchange_rate_adjusted_amount{ amount }
    currency_code { 'usd' }
    deposit_method_code { 'bank' }
    external_id { "1" }
    country { 'AR' }
    deposit_date { DateTime.now.utc }

    factory :fund_deposit_with_person do
      association :person, factory: :empty_person
    end
  end

  factory :alt_fund_deposit, class: FundDeposit do
    amount { 45000 }
    exchange_rate_adjusted_amount{ amount / 45.0 }
    currency_code { 'ars' }
    deposit_method_code { 'debin' }
    external_id { "2" }
    country { 'AR' }
    deposit_date { DateTime.now.utc }

    factory :alt_fund_deposit_with_person do
      association :person, factory: :empty_person
    end
  end

  factory :an_fund_deposit, class: FundDeposit do
    amount { 45000 }
    exchange_rate_adjusted_amount{ amount / 45.0 }
    currency_code { 'usd' }
    deposit_method_code { 'debin' }
    external_id { "2" }
    country { 'AN' }
    deposit_date { DateTime.now.utc }

    factory :an_fund_deposit_with_person do
      association :person, factory: :empty_person
    end
  end
end
