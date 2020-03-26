FactoryBot.define do
  factory :full_fund_transfer, class: FundTransfer do
    amount { 1000 }
    exchange_rate_adjusted_amount{ amount }
    currency_code { 'usd' }
    external_id { '2' }
    transfer_date { DateTime.now.utc }
  end

  factory :fund_transfer, class: FundTransfer do
    amount { 1000 }
    exchange_rate_adjusted_amount{ amount }
    currency_code { 'usd' }
    external_id { '2' }
    transfer_date { DateTime.now.utc }

    factory :fund_transfer_with_people do
      association :source_person, factory: :empty_person
      association :target_person, factory: :empty_person
    end
  end

  factory :alt_fund_transfer, class: FundTransfer do
    amount { 45000 }
    exchange_rate_adjusted_amount{ amount / 45.0 }
    currency_code { 'ars' }
    external_id { '2' }
    transfer_date { DateTime.now.utc }

    factory :alt_fund_transfer_with_people do
      association :source_person, factory: :empty_person
      association :target_person, factory: :empty_person
    end
  end
end
