ActiveAdmin.register FundDeposit do
  menu false
  actions :show, :index

  filter :created_at
  filter :currency_id, as: :select, collection: Currency.all
  filter :amount
  filter :exchange_rate_adjusted_amount
  filter :deposit_method_id, as: :select, collection: DepositMethod.all
  filter :external_id 

end
