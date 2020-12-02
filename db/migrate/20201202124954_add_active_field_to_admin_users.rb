class AddActiveFieldToAdminUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_users, :active, :boolean, null: false, default: true
  end
end
