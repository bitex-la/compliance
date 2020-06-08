ActiveAdmin.register AdminUser do
  menu priority: 3, if: -> { authorized?(:view_menu, AdminUser) }

  permit_params do
    params = [:password, :password_confirmation]
    params << [:email, :max_people_allowed] if authorized?(:full_update, AdminUser)
    params << [admin_user_taggings_attributes: [:tag_id, :id]] if authorized?(:full_update, AdminUser)
    params
  end

  actions :all, except: :destroy
  batch_action :destroy, false

  AdminUser.role_types.map(&:first).each do |role|
    action_item role, only: [:show] do
      if authorized?("grant_#{role}_access", resource) && current_admin_user != resource && !resource.is_in_role?(role)
        link_to "Grant #{role.camelize.capitalize} access", ["grant_#{role}_access", :admin_user], method: :post
      end
    end

    member_action "grant_#{role}_access", method: :post do
      authorize!("grant_#{role}_access", resource)
      resource.update!(role_type: role)
      redirect_to action: :show
    end
  end

  controller do
    def toogle_otp
      resource.update!(otp_enabled: !resource.otp_enabled)
      redirect_back notice: "OTP #{resource.otp_enabled? ? 'enabled' : 'disabled'}", fallback_location: root_path
    end

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

    def update
      if params[:admin_user][:password].blank? && params[:admin_user][:password_confirmation].blank?
        params[:admin_user].delete(:password)
        params[:admin_user].delete(:password_confirmation)
      end
      super
    end
  end

  index download_links: [:csv] do
    selectable_column
    id_column
    column :email
    column :role_type
    column :otp_enabled
    column :current_sign_in_at
    column :sign_in_count
    if authorized?(:full_read, AdminUser)
      column :max_people_allowed
      column(:person_view_count) do |o|
        o.request_limit_set.length
      end
      column(:rejected_person_view_count) do |o|
        o.request_limit_rejected_set.length
      end
    end
    column :created_at
    actions
  end

  filter :email
  filter :role_type, as: :select, collection: AdminUser.role_types
  filter :otp_enabled
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at
  filter :tags_id, as: :select,
    collection: proc { Tag.people },
    multiple: true

  action_item :enable_otp, only: :show do
    next unless authorized? :enable_otp, resource
    next if resource.otp_enabled?

    link_to('Enable OTP', enable_otp_admin_user_path(resource), method: :post)
  end

  action_item :disable_otp, only: :show do
    next unless authorized? :disable_otp, resource
    next if !resource.otp_enabled?

    link_to('Disable OTP', disable_otp_admin_user_path(resource), method: :post)
  end

  member_action :enable_otp, method: :post do
    toogle_otp
  end

  member_action :disable_otp, method: :post do
    toogle_otp
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :email if authorized?(:full_update, AdminUser)
      f.input :password
      f.input :password_confirmation
      f.input :max_people_allowed if authorized?(:full_update, AdminUser)
    end

    if authorized?(:full_update, AdminUser)
      ArbreHelpers::Form.has_many_form self, f, :admin_user_taggings,
        new_button_text: "Add New Tag" do |cf, context|
          cf.input :tag, as:  :select, collection: Tag.people
      end
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :email
      row :role_type
      row :otp_enabled
      row :sign_in_count
      row :current_sign_in_at
      row :last_sign_in_at
      row :current_sign_in_ip
      row :last_sign_in_ip
      row :created_at
      row :updated_at
      if authorized?(:full_read, resource)
        row :max_people_allowed
        row :tags do
          resource.tags.pluck(:name).join(' - ')
        end
      end
    end
  end

  csv do
    column :id
    column :email
    column :reset_password_sent_at
    column :remember_created_at
    column :sign_in_count
    column :current_sign_in_at
    column :last_sign_in_at
    column :current_sign_in_ip
    column :last_sign_in_ip
    column :created_at
    column :updated_at
    column :otp_enabled
    column :role_type
    if authorized?(:full_read, AdminUser)
      column :max_people_allowed
      column :tags do |o|
        o.tags.pluck(:name).join(' - ')
      end
    end
  end

  sidebar 'OTP info', only: :show, if: -> { authorized?(:enable_otp, resource) } do
    if resource.otp_enabled?
      span 'OTP already enabled'
    else
      resource.renew_otp_secret_key!
      div(class: 'qrcode', 'data-provisioning-uri' => resource.provisioning_uri("Compliance Admin | #{resource.email}"))
      attributes_table_for resource do
        row :otp_secret_key
      end
    end
  end
end
