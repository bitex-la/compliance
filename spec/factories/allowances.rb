FactoryBot.define_persons_item_and_seed(:allowance,
  salary_allowance: proc {
    weight 1_000
    amount 1_000
    kind "USD"
  },
  savings_allowance: proc {
    weight 1_000
    amount 1_000
    kind "USD"
  }
)
