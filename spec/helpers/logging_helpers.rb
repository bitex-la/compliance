module LoggingHelpers
  def assert_logging(entity, verb, expected_count)
    EventLog.where(entity: entity, verb_id: EventLogKind.send(verb).id).count.should == expected_count
  end
end

RSpec.configuration.include LoggingHelpers