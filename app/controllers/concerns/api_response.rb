module ApiResponse
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :jsonapi_422
    rescue_from ActiveRecord::RecordNotFound, with: :jsonapi_404
  end

  def json_response(object, status = 200)
    render json: object, status: status
  end

  def jsonapi_response(it, options = {}, status = 200)
    payload = it.is_a?(Array) ? it.first : it
    serializer = "#{payload.try(:klass) || payload.class}Serializer".constantize
    unless serializer.relationships_to_serialize.nil?
      options[:include] = serializer.relationships_to_serialize.keys
    end
    ser = serializer.new(it, options)
    body = ser.serialized_json
    json_response body, status
  end

  def error_response(errors)
    error_data, status = JsonApi::ErrorsSerializer.call(errors)
    json_response error_data, status
  end

  def jsonapi_422(exception)
    jsonapi_error(422, 'unprocessable_entity')
  end

  def jsonapi_404(exception)
    jsonapi_error(404, 'not_found')
  end

  def jsonapi_403
    jsonapi_error(403, 'forbidden')
  end

  def jsonapi_error(status, text)
    json_response({ errors: [{
      links:   {},
      status:  status,
      code:    text,
      title:   text,
      detail:  text,
      source:  {},
      meta:    {}
    }]}, status)
  end
end
