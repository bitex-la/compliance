module AdminUserHelper
  def with_untagged_admin
    old_admin = AdminUser.current_admin_user
    AdminUser.current_admin_user = create(:admin_user)
    result = yield
    AdminUser.current_admin_user = old_admin
    result
  end
end

RSpec.configuration.include AdminUserHelper
