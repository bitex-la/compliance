FactoryBot.define do
  factory :admin_user, class: 'AdminUser' do
    email     { Faker::Internet.email }
    password  { 'mysecurepassword' }
    api_token { 'my_super_secure_token_for_testing' }
    role_type { "admin" }
  end

  factory :other_admin_user, class: 'AdminUser' do
    email     { Faker::Internet.email }
    password  { 'mysecurepassword' }
    api_token { 'my_other_super_secure_token_for_testing' }
    role_type { "admin" }
  end

  factory :restricted_admin_user, class: 'AdminUser' do
    email     { Faker::Internet.email }
    password  { 'myrestrictedpassword' }
    api_token { 'my_restricted_token_for_testing' }
    role_type { "restricted" }
  end

  factory :super_admin_user, class: 'AdminUser' do
    email     { Faker::Internet.email }
    password  { 'mysecurepassword' }
    api_token { 'my_super_admin_secure_token_for_testing' }
    role_type { "super_admin" }
  end

  factory :limited_people_allowed_admin_user, class: 'AdminUser' do
    email     { Faker::Internet.email }
    password  { 'mysecurepassword' }
    api_token { 'my_super_admin_secure_token_for_testing' }
    role_type { "super_admin" }
    max_people_allowed { 3 }
  end
end
