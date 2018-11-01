FactoryBot.define_persons_item_and_seed(:allowance,
  salary_allowance: proc {
    weight { 1_000 }
    amount { 1_000 }
    kind_code { 'ars' }
    transient { add_all_attachments { true } }
  },
  savings_allowance: proc {
    weight { 1_000 }
    amount { 1_000 }
    kind_code { 'ars' }
    transient { add_all_attachments { true } }
  },
  alt_salary_allowance: proc {
    weight { 2_000 }
    amount { 2_000 }
    kind_code { 'vef' }
    transient { add_all_attachments { true } }
  },
  heavy_allowance: proc {
    weight { 2_000_000 }
    amount { 2_000_000 }
    kind_code { 'usd' }
    transient { add_all_attachments { true } }
  }
)