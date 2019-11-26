# frozen_string_literal: true

module Permission
  class PermissionValidator
    include StaticModels::Model

    static_models_dense [
      [:id, :code,          :provider],
      [1,   :admin,         'Permissions::AdminPermission'],
      [2,   :restricted,    'Permissions::RestrictedPermission'],
      [3,   :marketing,     'Permissions::MarketingPermission']
    ]

    def to_s
      code.to_s.upcase
    end

    def self.find_by_code(code)
      all.find { |c| c.code == code.to_s.downcase.to_sym }
    end

    def self.authorized?(user, action, subject = nil)
      return true if user.is_super_admin?

      klass = subject.class == Class ? subject : subject.class

      permission = self.find_by_code(user.role_type)
        .provider.constantize.new

      return true if [:read, :create, :update].include?(action) && permission.allowed_classes.include?(klass)

      permission.allowed_actions[klass].include?(action)
    end
  end
end
