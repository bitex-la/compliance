ActiveAdmin.register AdminUser do
  menu priority: 3, if: -> { !current_admin_user.is_restricted }
  permit_params :email, :password, :password_confirmation, :is_restricted

  index do
    selectable_column
    id_column
    column :email
    column :is_restricted
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :is_restricted
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs do
      f.input :email
      f.input :is_restricted
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
