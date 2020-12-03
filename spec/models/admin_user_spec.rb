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

  it 'can manage tags' do
    person_tag = create(:person_tag, name: 'new-tag')
    admin_user = create(:full_admin_user_tagging).admin_user
    expect(admin_user.can_manage_tag?(admin_user.tags.first)).to be_truthy
    expect(admin_user.can_manage_tag?(person_tag)).to be_falsey
    admin_user.tags << person_tag
    expect(admin_user.can_manage_tag?(admin_user.tags.first)).to be_truthy
    expect(admin_user.can_manage_tag?(person_tag)).to be_truthy
  end

  it 'disable user' do
    admin = create(:admin_user)
    expect(admin.active).to eq(true)
    admin.disable!
    expect(admin.active).to eq(false)
  end

  it 'not authorized to disable user' do
    admin = create(:admin_user, admin_role: AdminRole.marketing)
    expect(admin.active).to eq(true)
    expect { admin.disable! }
      .to raise_error(DisableNotAuthorized)
  end
end
