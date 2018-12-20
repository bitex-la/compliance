class AddOtpSecretKeyToAdmin < ActiveRecord::Migration[5.1]
  def change
    add_column :admin_users, :otp_secret_key, :string
    add_column :admin_users, :otp_enabled, :boolean, default: false 
  end
end
