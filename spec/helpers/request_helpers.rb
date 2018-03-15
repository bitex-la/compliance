module RequestHelpers
  def json_response
    JSON.parse(response.body).deep_symbolize_keys
  end

  def api_response
    JSON.parse(response.body, object_class: OpenStruct)
  end
end

RSpec.configuration.include RequestHelpers, type: :request
RSpec.configuration.include RequestHelpers, type: :feature
