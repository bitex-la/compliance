module AdminUserHelper
  def with_untagged_admin
    old_admin = AdminUser.current_admin_user
    AdminUser.current_admin_user = create(:admin_user)
    yield
  ensure
    AdminUser.current_admin_user = old_admin
  end
end

RSpec.configuration.include AdminUserHelper
