module RequestHelpers
  def json_response
    JSON.parse(response.body).deep_symbolize_keys
  end
end

RSpec.configuration.include RequestHelpers, type: :request
