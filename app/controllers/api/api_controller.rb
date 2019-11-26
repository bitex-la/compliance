class Api::ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  include ApiResponse

  before_action :require_token
  before_action :validate_restricted_user

  private

  def require_token
    AdminUser.current_admin_user || jsonapi_403
  end

  def allow_restricted_user
    true
  end

  def validate_restricted_user
    return jsonapi_403 if !allow_restricted_user && AdminUser.current_admin_user.is_restricted?
  end
end
