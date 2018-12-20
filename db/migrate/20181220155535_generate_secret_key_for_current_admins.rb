class GenerateSecretKeyForCurrentAdmins < ActiveRecord::Migration[5.1]
  def up
    AdminUser.all.each { |admin| admin.update_attribute(:otp_secret_key, ROTP::Base32.random_base32) }
  end
end
