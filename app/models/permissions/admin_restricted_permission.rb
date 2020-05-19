# frozen_string_literal: true

module Permissions
  class AdminRestrictedPermission < RestrictedPermission
    def initialize(user)
      super(user)
    end

    def allowed_classes
      super + 
      [
        EventLog
      ]
    end

    def allowed_actions
      actions = {
        EventLog => [:view_menu],
        AdminUser => [:read]
      }
      actions.default = []
      actions
    end
  end
end
