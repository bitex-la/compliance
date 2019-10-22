ActiveAdmin.register AdminUser do
  menu priority: 3, if: -> { authorized?(:view_menu, AdminUser) }
  permit_params :email, :password, :password_confirmation

  AdminUser.role_types.map(&:first).each do |role|
    action_item role, only: [:show, :edit, :update] do
      if authorized?(role, resource) && current_admin_user != resource && !resource.is_in_role?(role)
        link_to "#{role.camelize.capitalize} access", [role, :admin_user], method: :post
      end
    end

    member_action role, method: :post do
      authorize!(role, resource)
      resource.update!(role_type: role)
      redirect_to action: :show
    end
  end

  controller do
    def index
      authorize!(:index, AdminUser)
      super
    end

    def show
      if current_admin_user != resource && !current_admin_user.is_super_admin?
        redirect_to admin_user_url(current_admin_user)
        return
      end
      super
    end

    def destroy
      authorize!(:destroy, resource)

      if current_admin_user == resource
        flash[:error] = "can't delete himself"
        redirect_to action: :index
        return
      end

      super
    end
  end

  index do
    selectable_column
    id_column
    column :email
    column :role_type
    column :otp_enabled
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :role_type, as: :select, collection: AdminUser.role_types
  filter :otp_enabled
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  action_item :toggle_otp, only: :show do
    if authorized?(:toggle_otp, resource)
      text = resource.otp_enabled? ? 'Disable OTP' : 'Enable OTP'
      link_to(text, otp_admin_user_path(resource), method: :post)
    end
  end

  member_action :otp, method: :post do
    authorize!(:toggle_otp, resource)
    resource.update!(otp_enabled: !resource.otp_enabled)
    redirect_to admin_user_path(resource), notice: "OTP #{resource.otp_enabled? ? 'enabled' : 'disabled'}"
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  sidebar 'OTP', only: :show do
    if resource.otp_enabled?
      span 'OTP is enabled'
    else
      div(class: 'qrcode', 'data-provisioning-uri' => resource.provisioning_uri("Compliance Admin | #{resource.email}"))
      attributes_table_for resource do
        row :otp_secret_key
      end
    end
  end
end
