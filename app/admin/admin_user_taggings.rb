ActiveAdmin.register AdminUserTagging do
  menu false
  actions :destroy

  controller do
    def destroy
      super do |f|
        f.html { redirect_to edit_admin_user_url(resource.admin_user) }
      end
    end
  end
end
