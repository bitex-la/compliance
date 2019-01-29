class Api::Public::ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  include ApiResponse

  before_action :require_token

  private
  
  def require_token
    authenticate_token || jsonapi_403
  end

  def authenticate_token
    token = request.headers['Authorization'].gsub(/Token token=/, '')
    if current_person
      request.env['api_token'] = token
    end
  end

  def current_person
    token = request.headers['Authorization'].gsub(/Token token=/, '')
    Person.find_by(api_token: token)
  end
end
