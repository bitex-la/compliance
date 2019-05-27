module LoggingHelpers
  def assert_logging(entity, verb, expected_count)
    logs = EventLog.where(entity: entity, verb_id: EventLogKind.send(verb).id)    
    logs.count.should == expected_count
    yield logs.last if block_given?
  end
end

RSpec.configuration.include LoggingHelpers