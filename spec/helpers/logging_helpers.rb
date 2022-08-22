module LoggingHelpers
  def assert_logging(entity, verb, expected_count, check_sqs = true)
    event_kind = EventLogKind.send(verb)
    logs = EventLog.where(entity: entity, verb_id: event_kind.id)
    logs.count.should == expected_count
    last_log = logs.last

    if Settings.sqs.publish && check_sqs && expected_count > 0
      msgs = []
      EventLog.sqs_poller
        .poll(wait_time_seconds: 0, max_number_of_messages: 10, idle_timeout: 0) do |batch|
          batch.each { |m| msgs << JSON.parse(m.body, symbolize_names: true) }
        end
      expected_msg = %i[id entity_type entity_id].map { |k| [k, last_log.send(k)] }.to_h
      expected_msg[:verb_code] = last_log.verb_code.to_s
      expect(msgs).to include expected_msg
    end

    yield last_log if block_given?
  end
end

RSpec.configuration.include LoggingHelpers
