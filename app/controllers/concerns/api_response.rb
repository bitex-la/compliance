module ApiResponse
  def json_response(object, status = 200)
    render json: object, status: status
  end
end