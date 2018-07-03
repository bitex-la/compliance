FactoryBot.define_persons_item_and_seed(:risk_score,
  full_risk_score: proc {
    score           'green'
    provider        'chainalysis'
    extra_info      '{"userId":"5","creationDate":1530564049,"lastActivity":1530564049,"score":"green","scoreUpdatedDate":1530564070,"exposureDetails":[]}'
    external_link   'https://test.chainalysis.com'
    transient{ add_all_attachments true }
  }
)