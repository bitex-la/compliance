# frozen_string_literal: true

module Permissions
  class MarketingPermission < PermissionBase
    def initialize(user)
      super(user)
    end

    def allowed_classes
      []
    end

    def allowed_actions
      actions = {
        AdminUser => [:read],
        Person => [:read]
      }
      actions.default = []
      actions
    end
  end
end
