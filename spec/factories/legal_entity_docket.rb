FactoryBot.define_persons_item_and_seed(:legal_entity_docket,
  full_legal_entity_docket: proc {
    industry "software"
    business_description "To conquer the galaxy"
    country "Argentina"
    commercial_name "E Corp"
    legal_name "E Corp"
    transient{ add_all_attachments true }
  }
)
