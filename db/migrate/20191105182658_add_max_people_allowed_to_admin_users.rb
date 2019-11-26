class AddMaxPeopleAllowedToAdminUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_users, :max_people_allowed, :integer, null: true
  end
end
