require 'rails_helper'

describe 'an admin user' do
  let(:compliance_user) { create(:compliance_admin_user, otp_enabled: true) }
  let(:admin_user) { create(:admin_user, otp_enabled: true) }

  it 'can enable OTP and login with 2FA' do
    admin_user.update_column('otp_enabled', false)

    login_as_admin admin_user

    click_link 'Admin Users'

    within "tr[id='admin_user_#{admin_user.id}'] td[class='col col-actions']" do
      click_link 'View'
    end

    admin_user.reload

    within '#otp-info_sidebar_section' do
      expect(page).to have_content 'Otp'
      expect(page).to have_content admin_user.otp_secret_key
    end

    click_link 'Enable OTP'
    within '.flash_notice' do
      expect(page).to have_content 'OTP enabled'
    end

    within '#otp-info_sidebar_section' do
      expect(page).to have_content 'OTP already enabled'
    end

    click_link 'Logout'

    login_as(admin_user)

    click_link 'Admin Users'

    within "tr[id='admin_user_#{admin_user.id}'] td[class='col col-actions']" do
      click_link 'View'
    end

    within '#otp-info_sidebar_section' do
      expect(page).to have_content 'OTP already enabled'
    end

    click_link 'Disable OTP'

    expect(admin_user.reload.otp_enabled).to be_falsey
  end
end
