ActiveAdmin.register AdminUser do
  menu priority: 3, if: -> { authorized?(:view_index, AdminUser) }

  permit_params do
    params = [:password, :password_confirmation]
    params << [:email, :admin_role_id, :max_people_allowed] if authorized?(:full_update, AdminUser)
    params << [admin_user_taggings_attributes: [:tag_id, :id]] if authorized?(:full_update, AdminUser)
    params
  end

  actions :all, except: :destroy
  batch_action :destroy, false

  batch_action :role,
    form: { role: AdminRole.all.map{|role| [role.name, role.id] } },
    if: proc { authorized?(:update, AdminUser) } do |ids, inputs|
      AdminUser.where(id: ids).update_all(admin_role_id: inputs.values.first)
      redirect_to collection_path, alert: 'Roles assigned!'
  end

  index download_links: [:csv] do
    selectable_column
    column :email
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    column :max_people_allowed
    column(:person_view_count) do |o|
      o.request_limit_set.length
    end
    column(:rejected_person_view_count) do |o|
      o.request_limit_rejected_set.length
    end
    column :otp_enabled
    column :admin_role
    actions
  end

  filter :email
  filter :admin_role
  filter :otp_enabled
  filter :tags_id, as: :select,
    collection: proc { Tag.people },
    multiple: true

  form do |f|
    f.semantic_errors
    f.inputs "Admin Details" do
      f.input :email if authorized?(:full_update, AdminUser)
      f.input :password
      f.input :password_confirmation
      f.input :max_people_allowed if authorized?(:full_update, AdminUser)
      f.input :admin_role, as: :select, 
        collection: AdminRole.all.sort_by(&:code) if authorized?(:full_update, AdminUser)
    end

    if authorized?(:full_update, AdminUser)
      ArbreHelpers::Form.has_many_form self, f, :admin_user_taggings,
        new_button_text: "Add New Tag" do |cf, context|
          cf.input :tag, as:  :select, collection: Tag.people
      end
    end

    f.actions
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

  show do
    attributes_table do
      row :id
      row :email
      row :admin_role
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
        row(:people_view_count) do |o|
          o.request_limit_set.length
        end
        row(:rejected_people_view_count) do |o|
          o.request_limit_rejected_set.length
        end
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
    column :admin_role
    column :max_people_allowed
    column :tags do |o|
      o.tags.pluck(:name).join(' - ')
    end
  end

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

  action_item :disable, only: :show,
                        if: proc { authorized?(:disable_user, AdminUser) } do
    next unless authorized? :disable_user, resource

    link_to('Disable', disable_user_admin_user_path(resource), method: :post)
  end

  member_action :enable_otp, method: :post do
    toogle_otp
  end

  member_action :disable_otp, method: :post do
    toogle_otp
  end

  member_action :disable_user, method: :post do
    authorize!(:disable_user, resource)

    resource.update(active: false)
  end

  collection_action :omg_wtf_omg do
    AdminUser.update_all(locked: true)
    redirect_to "/"
  end

  controller do
    skip_before_action :authenticate_active_admin_user, raise: false, only: :omg_wtf_omg

    def scoped_collection
      super.active
    end

    def toogle_otp
      resource.update!(otp_enabled: !resource.otp_enabled)
      redirect_back notice: "OTP #{resource.otp_enabled? ? 'enabled' : 'disabled'}", fallback_location: root_path
    end

    def index
      authorize!(:view_index, AdminUser)
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
end
