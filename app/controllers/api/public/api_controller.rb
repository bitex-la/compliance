class Api::Public::ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  include ApiResponse

  before_action :require_token

  private
  
  def require_token
    authenticate_token || jsonapi_403
  end

  def authenticate_token
    #TODO: Parse token
    token = request.headers['Authorization']
    if Person.find_by(api_token: token)
      request.env['api_token'] = token
    end
  end
end
