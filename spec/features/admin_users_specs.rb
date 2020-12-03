require 'rails_helper'

describe 'AdminUser', js: true do
  it "Allowed roles can view all admin users" do
    roles = [AdminRole.security, AdminRole.super_admin]

    roles.each do |role|
      login_admin(admin_role: role)
      visit "/admin_users"
      expect(current_path).to eq("/admin_users")
      logout
    end
  end

  it "Not allowed roles can not view all admin users" do
    roles = [AdminRole.marketing,
      AdminRole.compliance,
      AdminRole.operations,
      AdminRole.commercial,
      AdminRole.restricted]

    roles.each do |role|
      login_admin(admin_role: role)
      visit "/admin_users"
      expect(current_path).not_to eq("/admin_users")
      logout
    end
  end

  it "All roles can view your own admin details" do
    roles = [AdminRole.marketing,
      AdminRole.compliance,
      AdminRole.operations,
      AdminRole.commercial,
      AdminRole.security,
      AdminRole.super_admin]

    roles.each do |role|
      login_admin(admin_role: role)
      visit "/admin_users/#{AdminUser.last.id}"
      expect(current_path).to eq("/admin_users/#{AdminUser.last.id}")
      logout
    end
  end

  it "Restricted roles cannot view others admin details" do
    roles = [AdminRole.marketing,
      AdminRole.compliance,
      AdminRole.operations,
      AdminRole.commercial]

    admin = create(:admin_user, admin_role: AdminRole.marketing)

    roles.each do |role|
      login_admin(admin_role: role)
      visit "/admin_users/#{admin.id}"
      expect(current_path).not_to eq("/admin_users/#{admin.id}")
      logout
    end
  end

  it "All roles can enable your own OTP" do
    roles = [AdminRole.marketing,
      AdminRole.compliance,
      AdminRole.operations,
      AdminRole.commercial,
      AdminRole.security,
      AdminRole.super_admin]

    roles.each do |role|
      login_admin(admin_role: role)
      admin = AdminUser.last
      visit "/admin_users/#{admin.id}"
      click_link 'Enable OTP'
      expect(page).to have_content 'OTP enabled'
      expect(admin.reload.otp_enabled).to be_truthy
      logout
    end
  end

  it "Allowed roles can disable OTP" do
    roles = [AdminRole.security, AdminRole.super_admin]

    roles.each do |role|
      admin = create(:admin_user, admin_role: AdminRole.marketing, otp_enabled: true)
      login_admin(admin_role: role)
      visit "/admin_users/#{admin.id}"
      click_link 'Disable OTP'
      expect(page).to have_content 'OTP disabled'
      expect(admin.reload.otp_enabled).to be_falsy
      logout
    end
  end

  it "Not allowed roles can not disable OTP" do
    roles = [AdminRole.marketing,
      AdminRole.compliance,
      AdminRole.operations,
      AdminRole.commercial]

    roles.each do |role|
      login_admin(admin_role: role)
      admin = AdminUser.last
      admin.update!(otp_enabled: true)
      visit "/admin_users/#{admin.id}"
      expect(page).not_to have_content 'Disable OTP'
      logout
    end
  end

  it "Allowed roles can full update admin users" do
    roles = [AdminRole.security, AdminRole.super_admin]

    roles.each do |role|
      admin = create(:admin_user, admin_role: AdminRole.marketing)
      login_admin(admin_role: role)
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
    roles = [AdminRole.marketing,
      AdminRole.compliance,
      AdminRole.operations,
      AdminRole.commercial,
      AdminRole.security,
      AdminRole.super_admin]

    roles.each do |role|
      login_admin(admin_role: role)
      admin = AdminUser.last
      visit "/admin_users/#{admin.id}/edit"
      fill_in :admin_user_password, with: 123456
      fill_in :admin_user_password_confirmation, with: 123456
      click_button 'Update Admin user'
      expect(AdminUser.last.encrypted_password).not_to eq(admin.encrypted_password)
      logout
    end
  end

  it 'only active users are shown' do
    create(:admin_user, email: 'active1@user.com')
    create(:admin_user, email: 'active2@user.com')
    create(:admin_user, email: 'inactive@user.com', active: false)
    login_admin
    visit '/admin_users'

    expect(page).to have_content 'active1@user.com'
    expect(page).to have_content 'active2@user.com'
    expect(page).not_to have_content 'inactive@user.com'
  end

  it 'inactive user does not allow login' do
    login_admin(active: false)

    expect(page).to have_content('Este usuario ha sido deshabilitado.')
  end

  it 'security user can disable another user' do
    admin_user = create(:admin_user, email: 'active1@user.com')

    login_admin(admin_role: AdminRole.security)
    visit '/admin_users'

    expect(page).to have_content 'active1@user.com'
    find(:xpath, "//a[@href='/admin_users/#{admin_user.id}']").click
    click_link 'Disable'
    expect(page).not_to have_content 'active1@user.com'
    expect(current_path).to eq('/admin_users')
  end

  it 'Disable button is not shown for itself' do
    user = create(:admin_user, admin_role: AdminRole.commercial)
    login_as user

    visit "/admin_users/#{user.id}"
    expect(page).not_to have_content 'Disable'
  end

  it "can't disable itself" do
    user = create(:admin_user, admin_role: AdminRole.commercial)
    login_as user

    visit "/admin_users/#{user.id}"

    page.execute_script %{
      $('body').append('<a rel="nofollow" data-method="post" href="/admin_users/#{user.id}/disable_user">Disable</a>')
    }
    click_link 'Disable'
    expect(page).to have_content 'You are not authorized to perform this action.'
  end

  describe 'restricted role' do
    it 'redirect to login' do
      login_admin(admin_role: AdminRole.restricted)
      expect(current_path).to eq("/login")
    end
  end
end
