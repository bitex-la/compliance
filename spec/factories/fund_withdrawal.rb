FactoryBot.define do
  factory :full_fund_withdrawal, class: FundWithdrawal do
    amount { 1000 }
    exchange_rate_adjusted_amount{ amount }
    currency_code { 'usd' }
    country { 'AR' }
    withdrawal_date { DateTime.now.utc }
  end

  factory :fund_withdrawal, class: FundWithdrawal do
    amount { 1000 }
    exchange_rate_adjusted_amount{ amount }
    currency_code { 'usd' }
    country { 'AR' }
    withdrawal_date { DateTime.now.utc }

    factory :fund_withdrawal_with_person do
      association :person, factory: :empty_person
    end
  end

  factory :alt_fund_withdrawal, class: FundWithdrawal do
    amount { 45000 }
    exchange_rate_adjusted_amount{ amount / 45.0 }
    currency_code { 'ars' }
    country { 'AR' }
    withdrawal_date { DateTime.now.utc }

    factory :alt_fund_withdrawal_with_person do
      association :person, factory: :empty_person
    end
  end
end
