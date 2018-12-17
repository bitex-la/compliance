class AddRestrictedAccessFlag < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_users, :is_restricted, :boolean, default: false 
  end
end
