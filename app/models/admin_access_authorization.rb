class AdminAccessAuthorization < ActiveAdmin::AuthorizationAdapter
  def authorized?(action, subject = nil)
    Permission::PermissionValidator.authorized?(user, action, subject)
  end
end