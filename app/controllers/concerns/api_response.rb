module ApiResponse
  def json_response(object, status = 200)
    render json: object, status: status
  end

  def jsonapi_response(resource, options = {}, status = 200)
    klass = resource.try(:klass) || resource.class
    body = "#{klass.to_s}Serializer".constantize.new(resource, options).serialized_json 
    json_response body, status
  end

  def error_response(errors)
    error_data, status = JsonApi::ErrorsSerializer.call(errors)
    json_response error_data, status
  end
end
