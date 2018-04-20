class AddTokenToAdminUser < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_users, :api_token, :string
  end
end
