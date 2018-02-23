module ApiResponse
  def json_response(object, status = 200)
    render json: object, status: status
  end

  def jsonapi_response(it, options = {}, status = 200)
    serializer = "#{it.try(:klass) || it.class}Serializer".constantize
		options[:include] = serializer.relationships_to_serialize.keys
    body = serializer.new(it, options).serialized_json 
    json_response body, status
  end

  def error_response(errors)
    error_data, status = JsonApi::ErrorsSerializer.call(errors)
    json_response error_data, status
  end
end
