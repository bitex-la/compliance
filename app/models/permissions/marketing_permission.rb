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
      Hash.new([]).merge(
        AdminUser => [:read],
        Person => [:read]
      )
    end
  end
end
