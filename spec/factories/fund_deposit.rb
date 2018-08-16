FactoryBot.define do 
  factory :full_fund_deposit, class: FundDeposit do 
    amount 1000
    currency_id Currency.find(4).id
    deposit_method_id DepositMethod.find(1).id
    external_id 1
  end

  factory :fund_deposit, class: FundDeposit do 
    amount 1000
    currency_id Currency.find(4).id
    deposit_method_id DepositMethod.find(1).id
    external_id 1
  end
end
