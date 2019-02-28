ActiveAdmin.register TaskType  do
  menu priority: 6, if: -> { !current_admin_user.is_restricted }
  actions :all, except: :destroy

  index do
    column :id
    column :name
    column :description
    actions
  end
end