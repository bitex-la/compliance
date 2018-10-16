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
  google_robot_score: proc {
    score { 'green' }
    provider { 'google' }
    extra_info { '' }
    external_link { 'https://www.google.com/search?q=E%20Corp%20LLC%20AND%20bankruptcy%20OR%20trafficking%20OR%20laundering%20OR%20sanction%20OR%20fraud%20OR%20bribery%20OR%20terrorism%20OR%20corruption%20OR%20evasion%20OR%20drug%20trafficking%20OR%20theft%20OR%20bribe%20OR%20conspiracy%20OR%20cartel%20OR%20price%20fixing%20OR%20false%20accounting%20OR%20forgery%20OR%20smuggle,
      https://www.google.com/search?q=E%20Corp%20LLC%20AND%20bancarrota%20OR%20tr%C3%A1fico%20OR%20lavado%20OR%20sanci%C3%B3n%20OR%20fraude%20OR%20soborno%20OR%20terrorismo%20OR%20corrupci%C3%B3n%20OR%20evasi%C3%B3n%20OR%20narcotr%C3%A1fico%20OR%20robo%20OR%20coima%20OR%20conspiraci%C3%B3n%20OR%20cartel%20OR%20fijaci%C3%B3n%20de%20precios%20OR%20contabilidad%20falsa%20OR%20falsificaci%C3%B3n%20OR%20contrabando' } 
  }
)
