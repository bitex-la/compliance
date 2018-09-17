FactoryBot.define do 
  factory :event_log do
    factory :issue_creation_event_log do 
      entity_id { 1 }
      entity_type { 'Issue' }
      verb_code { 'create_entity' }
      raw_data { '{"foo": "bar"}' }
    end
    factory :person_update_event_log do 
      entity_id { 1 }
      entity_type { 'Person' }
      verb_code { 'update_entity' }
      raw_data { '{"foo": "bar"}' }
    end
  end
end
