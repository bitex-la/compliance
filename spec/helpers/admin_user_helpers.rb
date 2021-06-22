module AdminUserHelper
  def with_untagged_admin
    old_admin = AdminUser.current_admin_user
    AdminUser.current_admin_user = create(:admin_user)
    yield
  ensure
    AdminUser.current_admin_user = old_admin
  end

  def dememoize_admin_user_tags(admin_user)
    admin_user.class_eval do
      def active_tags
        admin_user_taggings.pluck(:tag_id)
      end
    end
  end
end

RSpec.configuration.include AdminUserHelper
