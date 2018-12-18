ActiveAdmin.register AdminUser do
  menu priority: 3, if: -> { !current_admin_user.is_restricted }
  permit_params :email, :password, :password_confirmation, :is_restricted

  action_item :restrict, only: [:show, :edit, :update], if: -> {!current_admin_user.is_restricted && !resource.is_restricted} do 
    link_to "Restrict", [:restrict, :admin_user], method: :post
  end
  action_item :give_full_access, only: [:show, :edit, :update], if: -> {!current_admin_user.is_restricted && resource.is_restricted} do 
    link_to "Give full access", [:give_full_access, :admin_user], method: :post
  end

  member_action :restrict, method: :post do
    resource.update!(is_restricted: true)
    redirect_to action: :show
  end

  member_action :give_full_access, method: :post do
    resource.update!(is_restricted: false)
    redirect_to action: :show
  end

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
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
