module ApiResponse
  def json_response(object, status = 200)
    render json: object, status: status
  end

  def error_response(errors)
    error_data, status = JsonApi::ErrorsSerializer.call(errors)
    json_response error_data, status
  end
end