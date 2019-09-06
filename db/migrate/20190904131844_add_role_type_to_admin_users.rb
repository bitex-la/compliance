class AddRoleTypeToAdminUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :admin_users, :role_type, :integer, null: false, default: 0 #restricted
    
    AdminUser.where('is_restricted = 0')
      .update_all(role_type: 1) #admin

    remove_column :admin_users, :is_restricted
  end

  def down
    add_column :admin_users, :is_restricted, :boolean, default: false 

    AdminUser.where('role_type = 0') #restricted
      .update_all(is_restricted: true) 

    remove_column :admin_users, :role_type
  end
end
