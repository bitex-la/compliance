# frozen_string_literal: true

module Permissions
  class PermissionBase
    attr_accessor :admin_user

    def initialize(user)
      self.admin_user = user
    end

    # override this method to add *classes* that allow
    # the following pre-defined actions
    # [:read, :create, :update]
    def allowed_classes
    end

    # override this method to add *classes* that allow
    # custom actions
    def allowed_actions
    end

    # override this method to add *instances* that allow
    # custom actions
    def allowed_instances
      Hash.new([]).merge(
        update: [admin_user],
        enable_otp: [admin_user]
      )
    end
  end
end
