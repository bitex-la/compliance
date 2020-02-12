require 'rails_helper'

describe AdminUser do
  it "auto-generates an api_token" do
    AdminUser.create(
      email: 'example@example.com',
      password: 'something',
      password_confirmation: 'something'
    ).api_token.should be_a(String)
  end

  it 'renew otp secret key only when otp is disabled' do
    admin = create(:admin_user)
    admin.update(otp_enabled: true)
    otp_key = admin.otp_secret_key
    admin.renew_otp_secret_key!
    expect(admin.otp_secret_key).to eq otp_key

    admin.update(otp_enabled: false)
    admin.renew_otp_secret_key!
    expect(admin.otp_secret_key).not_to eq otp_key
  end
end
