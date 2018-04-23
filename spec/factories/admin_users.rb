FactoryBot.define do
  factory :admin_user do
    email     'test@example.com'
    password  'mysecurepassword'
    api_token 'my_super_secure_token_for_testing'
  end
end
