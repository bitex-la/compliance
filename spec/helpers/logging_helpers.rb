module LoggingHelpers
  def assert_logging(entity, verb, expected_count, check_sqs = true)
    event_kind = EventLogKind.send(verb)
    logs = EventLog.where(entity: entity, verb_id: event_kind.id)
    logs.count.should == expected_count
    last_log = logs.last

    if check_sqs && expected_count > 0
      msgs = []
      EventLog.sqs_poller
        .poll(wait_time_seconds: 0, max_number_of_messages: 10, idle_timeout: 0) do |batch|
          batch.each { |m| msgs << JSON.parse(m.body, symbolize_names: true) }
        end
      found_event_msg = msgs.find { |msg| msg[:id] == last_log.id }
      expect(found_event_msg).not_to be_nil
    end

    yield last_log if block_given?
  end
end

RSpec.configuration.include LoggingHelpers
