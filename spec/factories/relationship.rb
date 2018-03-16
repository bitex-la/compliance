FactoryBot.define_persons_item_and_seed(:relationship,
  full_relationship: proc {
    kind    RelationshipKind.find(15).id
    association :related_person, factory: :empty_person
    transient{ add_all_attachments true }
  }
)
