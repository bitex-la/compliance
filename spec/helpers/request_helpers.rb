module RequestHelpers
  def forbidden_api_request(method, path, params)
    send(method, "/api#{path}", params: params,
      headers: { 'Authorization': "Token token=potato" })
    assert_response 403
  end

  def api_request(method, path, params = {}, expected_status = 200)
    admin = AdminUser.last || create(:admin_user)
    send(method, "/api#{path}", params: params,
      headers: { 'Authorization': "Token token=#{admin.api_token}" })
    assert_response expected_status
  end

  def api_get(path, params = {}, expected_status = 200)
    api_request(:get, path, params, expected_status)
  end

  def api_create(path, data, expected_status = 201)
    api_request(:post, path, {data: data}, expected_status)
  end

  def api_update(path, data, expected_status = 200)
    api_request(:patch, path, {data: data}, expected_status)
  end

  def json_response
    JSON.parse(response.body).deep_symbolize_keys
  end

  def api_response
    JSON.parse(response.body, object_class: OpenStruct)
  end
end

RSpec.configuration.include RequestHelpers, type: :request
RSpec.configuration.include RequestHelpers, type: :feature

module LoggingHelpers
  def assert_logging(entity, verb, expected_count)
    EventLog.where(entity: entity, verb_id: EventLogKind.send(verb).id).count.should == expected_count
  end
end
RSpec.configuration.include LoggingHelpers, type: :model
