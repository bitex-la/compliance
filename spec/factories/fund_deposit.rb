FactoryBot.define_persons_item_and_seed(:fund_deposit,
  full_fund_deposit: proc {
    amount 1000
    currency_id Currency.find(4).id
    deposit_method_id DepositMethod.find(1).id
    transient{ add_all_attachments true }
  }
)