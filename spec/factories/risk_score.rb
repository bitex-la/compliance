FactoryBot.define_persons_item_and_seed(:risk_score,
  full_risk_score: proc {
    score { 'green' }
    provider { 'chainalysis' }
    extra_info { '{"userId":"5","creationDate":1530564049,"lastActivity":1530564049,"score":"green","scoreUpdatedDate":1530564070,"exposureDetails":[]}' }
    external_link { 'https://test.chainalysis.com' }
    transient { add_all_attachments { true } }
  },
  alt_full_risk_score: proc {
    score { 'red' }
    provider { 'goldman sachs' }
    extra_info { '{"userId":"3","creationDate":1432123,"lastActivity":3345,"score":"red","scoreUpdatedDate":394374,"exposureDetails":[]}' }
    external_link { 'https://test.goldman_sachs.com' }
    transient { add_all_attachments { true } }
  }
)
