# frozen_string_literal: true

module Permissions
  class PermissionBase
    attr_accessor :admin_user

    def initialize(user)
      self.admin_user = user
    end

    def allowed_classes
    end

    def allowed_actions
    end

    def allowed_instances
      actions = {
        update: [admin_user],
        enable_otp: [admin_user]
      }
      actions.default = []
      actions
    end
  end
end
