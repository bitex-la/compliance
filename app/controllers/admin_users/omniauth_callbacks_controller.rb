# frozen_string_literal: true

module AdminUsers
  class OmniauthCallbacksController < ::Devise::OmniauthCallbacksController
    def google_oauth2
      admin_user = AdminUser.from_omniauth(request.env['omniauth.auth'])

      if admin_user
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
        sign_in_and_redirect admin_user, event: :authentication
      else
        flash[:alert] = I18n.t 'devise.omniauth_callbacks.failure', kind: 'Google', reason: 'user not allowed'
        redirect_to root_path
      end
    end

    def after_sign_in_path_for(admin_user)
      public_send("#{admin_user.admin_role.root_page}_path")
    end
  end
end
