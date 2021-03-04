FactoryBot.define_persons_item_and_seed(:legal_entity_docket,
  full_legal_entity_docket: proc {
    industry { "software" }
    business_description { "To conquer the galaxy" }
    country { "AR" }
    commercial_name { "E Corp" }
    legal_name { "E Corp" }
    transient{ add_all_attachments { true } }
    regulated_entity { true }
    operations_with_third_party_funds { true }
  },
  alt_full_legal_entity_docket: proc {
    industry { "agriculture" }
    business_description { "To harvest crops" }
    country { "UY" }
    commercial_name { "A Corp" }
    legal_name { "A Corp" }
    transient{ add_all_attachments { true } }
    regulated_entity { true }
    operations_with_third_party_funds { false }
  }
)
