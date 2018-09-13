FactoryBot.define_persons_item_and_seed(:affinity,
  full_affinity: proc {
    affinity_kind_code { :business_partner }
    association :related_person, factory: :empty_person
    transient{ add_all_attachments { true } }
  },
  alt_full_affinity: proc {
    affinity_kind_code { :spouse }
    association :related_person, factory: :empty_person
    transient{ add_all_attachments { true } }
  }
)
