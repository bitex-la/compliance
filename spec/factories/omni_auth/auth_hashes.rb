FactoryBot.define do
  factory :google_auth_hash, class: 'OmniAuth::AuthHash' do
    transient do
      email { create(:admin_user).email }
    end

    provider { 'google' }
    uid { '123456789' }
    info do
      {
        name: 'Matias',
        email: email
      }
    end
  end
end
