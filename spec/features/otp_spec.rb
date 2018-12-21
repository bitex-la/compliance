require 'rails_helper'

describe 'an admin user' do
  let(:admin_user) { create(:admin_user, otp_enabled: true) }

  it 'cannot login without otp if otp is enabled' do
    visit admin_user_session_path
    fill_in 'admin_user[email]', with: admin_user.email
    fill_in 'admin_user[password]', with: admin_user.password
    click_button 'Login'

    expect(page).to have_content 'Invalid OTP'
  end

  it 'can enable OTP and login with 2FA' do
    admin_user.update_column('otp_enabled', false)

    login_as admin_user

    click_link 'Admin Users'

    within "tr[id='admin_user_#{admin_user.id}'] td[class='col col-actions']" do
      click_link 'View'
    end

    within '#otp_sidebar_section' do
      expect(page).to have_content 'Otp'
      expect(page).to have_content admin_user.otp_secret_key
    end
    
    click_link 'Enable OTP'
    within '.flash_notice' do
      expect(page).to have_content 'OTP enabled'
    end
    
    within '#otp_sidebar_section' do
      expect(page).to have_content 'OTP is enabled'
    end

    click_link 'Logout'

    fill_in 'admin_user[email]', with: admin_user.email
    fill_in 'admin_user[password]', with: admin_user.password
    fill_in 'admin_user[otp]', with: admin_user.otp_code
    click_button 'Login'

    within '.flash_notice' do
      expect(page).to have_content 'Signed in successfully.'
    end

    click_link 'Admin Users'
    
    within "tr[id='admin_user_#{admin_user.id}'] td[class='col col-actions']" do
      click_link 'View'
    end

    within '#otp_sidebar_section' do
      expect(page).to have_content 'OTP is enabled'
    end

    click_link 'Disable OTP'

    expect(admin_user.reload.otp_enabled).to be_falsey
  end
end