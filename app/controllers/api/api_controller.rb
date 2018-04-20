class Api::ApiController < ApplicationController
  protect_from_forgery with: :null_session
  include ApiResponse

  before_action :require_token

  private
  
  def require_token
    authenticate_token || jsonapi_403
  end

  def authenticate_token
    authenticate_with_http_token do |token, options|
      AdminUser.find_by(api_token: token)
    end
  end
end
