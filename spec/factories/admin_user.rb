FactoryBot.define do
  factory :admin_user, class: 'AdminUser' do
    email     { Faker::Internet.email }
    password  { 'mysecurepassword' }
    api_token { 'my_super_secure_token_for_testing' }
  end

  factory :other_admin_user, class: 'AdminUser' do
    email     { Faker::Internet.email }
    password  { 'mysecurepassword' }
    api_token { 'my_other_super_secure_token_for_testing' }
  end

  factory :restricted_admin_user, class: 'AdminUser' do
    email     { Faker::Internet.email }
    password  { 'myrestrictedpassword' }
    api_token { 'my_restricted_token_for_testing' }
    is_restricted { true }
  end
end
