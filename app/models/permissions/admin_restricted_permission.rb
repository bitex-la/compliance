# frozen_string_literal: true

module Permissions
  class AdminRestrictedPermission < RestrictedPermission
    def initialize(user)
      super(user)
    end

    def allowed_classes
      super +
        [EventLog]
    end

    def allowed_actions
      Hash.new([]).merge(
        EventLog => [:view_menu],
        AdminUser => [:read]
      )
    end
  end
end
