class AddLockInfoToIssues < ActiveRecord::Migration[5.2]
  def change
    add_column :issues, :locked, :bool, null: false, default: false
    add_reference :issues, :lock_admin_user, foreign_key: { to_table: :admin_users }
    add_column :issues, :lock_expiration, :datetime
  end
end
