class EventLogSerializer
  include FastJsonapiCandy::Serializer
  set_type 'event_logs'

  attributes :raw_data, :entity_id, :entity_type, :verb_code

  build_timestamps
end
