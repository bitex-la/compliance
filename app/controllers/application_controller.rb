class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_current_user

  def set_current_user
    AdminUser.current_admin_user = current_admin_user
  end
end
