class RedirectController < ApplicationController
  def root
    if current_admin_user.nil?
      redirect_to '/login'
    else
      redirect_to "/#{current_admin_user.admin_role.root_page}"
    end
  end
end
