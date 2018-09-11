FactoryBot.define_persons_item_and_seed(:affinity,
  full_affinity: proc {
    affinity_kind_id { AffinityKind.find(15).id }
    association :related_person, factory: :empty_person
    transient{ add_all_attachments { true } }
  }
)
