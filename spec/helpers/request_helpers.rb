module RequestHelpers
  def json_response
    JSON.parse(response.body).deep_symbolize_keys
  end

  def api_response
    JSON.parse(response.body, object_class: OpenStruct)
  end

  def assert_logging(entity, verb, expected_count)
    EventLog.where(entity: entity, verb_id: EventLogKind.send(verb).id).count.should == expected_count
  end
end

RSpec.configuration.include RequestHelpers, type: :request
RSpec.configuration.include RequestHelpers, type: :feature
