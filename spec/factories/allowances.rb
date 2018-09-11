FactoryBot.define_persons_item_and_seed(:allowance,
  salary_allowance: proc {
    weight { 1_000 }
    amount { 1_000 }
    kind_code { "ars" }
    transient{ add_all_attachments { true } }
  },
  savings_allowance: proc {
    weight { 1_000 }
    amount { 1_000 }
    kind_code { "ars" }
    transient{ add_all_attachments { true } }
  }
)
