class RoutesController < ApplicationController
  def root
    if current_admin_user.nil?
      redirect_to '/login'
    else
      root_page = case current_admin_user.role_type
      when 'marketing'
        '/people'
      else
        '/dashboards'
      end
      redirect_to root_page
    end
  end
end
