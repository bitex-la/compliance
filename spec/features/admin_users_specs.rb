require 'rails_helper'

describe 'AdminUser', js: true do
  it "Allowed roles can view all admin users" do
    roles = [:super_admin]

    roles.each do |role|
      login_admin(role_type: role)
      visit "/admin_users"
      expect(current_path).to eq("/admin_users")
      logout
    end
  end

  it "Not allowed roles can not view all admin users" do
    roles = [:admin,
      :admin_restricted,
      :restricted,
      :marketing]

    roles.each do |role|
      login_admin(role_type: role)
      visit "/admin_users"
      expect(current_path).not_to eq("/admin_users")
      logout
    end
  end

  it "All roles can view your own admin details" do
    roles = [:admin,
      :admin_restricted,
      :restricted,
      :marketing,
      :super_admin]

    roles.each do |role|
      login_admin(role_type: role)
      visit "/admin_users/#{AdminUser.last.id}"
      expect(current_path).to eq("/admin_users/#{AdminUser.last.id}")
      logout
    end
  end

  it "Restricted roles cannot view others admin details" do
    roles = [:admin,
      :admin_restricted,
      :restricted,
      :marketing]

    admin = create(:admin_user, role_type: :marketing)

    roles.each do |role|
      login_admin(role_type: role)
      visit "/admin_users/#{admin.id}"
      expect(current_path).not_to eq("/admin_users/#{admin.id}")
      logout
    end
  end

  it "All roles can enable your own OTP" do
    roles = [:admin,
      :admin_restricted,
      :restricted,
      :marketing,
      :super_admin]

    roles.each do |role|
      login_admin(role_type: role)
      admin = AdminUser.last
      visit "/admin_users/#{admin.id}"
      click_link 'Enable OTP'
      expect(page).to have_content 'OTP enabled'
      expect(admin.reload.otp_enabled).to be_truthy
      logout
    end
  end

  it "Allowed roles can disable OTP" do
    roles = [:super_admin]

    roles.each do |role|
      admin = create(:admin_user, role_type: :marketing, otp_enabled: true)
      login_admin(role_type: role)
      visit "/admin_users/#{admin.id}"
      click_link 'Disable OTP'
      expect(page).to have_content 'OTP disabled'
      expect(admin.reload.otp_enabled).to be_falsy
      logout
    end
  end

  it "Not allowed roles can not disable OTP" do
    roles = [:admin,
      :admin_restricted,
      :restricted,
      :marketing]

    roles.each do |role|
      login_admin(role_type: role)
      admin = AdminUser.last
      admin.update!(otp_enabled: true)
      visit "/admin_users/#{admin.id}"
      expect(page).not_to have_content 'Disable OTP'
      logout
    end
  end

  it "Allowed roles can full update admin users" do
    roles = [:super_admin]

    roles.each do |role|
      admin = create(:admin_user, role_type: :marketing)
      login_admin(role_type: role)
      visit "/admin_users/#{admin.id}/edit"

      fill_in :admin_user_max_people_allowed, with: 5000
      fill_in :admin_user_password, with: 123456
      fill_in :admin_user_password_confirmation, with: 123456

      click_button 'Update Admin user'
      expect(page).to have_content 'Admin user was successfully updated.'

      admin.reload
      expect(admin.max_people_allowed).to eq(5000)
      logout
    end
  end

  it "All roles can update your own password" do
    roles = [:admin,
      :admin_restricted,
      :restricted,
      :marketing,
      :super_admin]

    roles.each do |role|
      login_admin(role_type: role)
      admin = AdminUser.last
      visit "/admin_users/#{admin.id}/edit"
      fill_in :admin_user_password, with: 123456
      fill_in :admin_user_password_confirmation, with: 123456
      click_button 'Update Admin user'
      expect(AdminUser.last.encrypted_password).not_to eq(admin.encrypted_password)
      logout
    end
  end
end
