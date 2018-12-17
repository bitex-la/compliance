FactoryBot.define do
  factory :admin_user, class: 'AdminUser' do
    email     { 'test@example.com' }
    password  { 'mysecurepassword' }
    api_token { 'my_super_secure_token_for_testing' }
  end

  factory :restricted_admin_user, class: 'AdminUser' do
    email     { 'test_restricted@example.com' }
    password  { 'myrestrictedpassword' }
    api_token { 'my_restricted_token_for_testing' }
    is_restricted { true }
  end
end
