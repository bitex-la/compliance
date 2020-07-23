FactoryBot.define do
  factory :admin_user, class: 'AdminUser' do
    email     { Faker::Internet.email }
    password  { 'mysecurepassword' }
    api_token { 'my_super_secure_token_for_testing' }
    admin_role AdminRole.compliance
    max_people_allowed { 1000 }
  end

  factory :other_admin_user, class: 'AdminUser' do
    email     { Faker::Internet.email }
    password  { 'mysecurepassword' }
    api_token { 'my_other_super_secure_token_for_testing' }
    admin_role AdminRole.compliance
    max_people_allowed { 1000 }
  end

  factory :restricted_admin_user, class: 'AdminUser' do
    email     { Faker::Internet.email }
    password  { 'myrestrictedpassword' }
    api_token { 'my_restricted_token_for_testing' }
    admin_role AdminRole.compliance
    max_people_allowed { 1000 }
  end

  factory :admin_restricted_user, class: 'AdminUser' do
    email     { Faker::Internet.email }
    password  { 'myadminrestrictedpassword' }
    api_token { 'my_admin_restricted_token_for_testing' }
    admin_role AdminRole.restricted
    max_people_allowed { 1000 }
  end

  factory :super_admin_user, class: 'AdminUser' do
    email     { Faker::Internet.email }
    password  { 'mysecurepassword' }
    api_token { 'my_super_admin_secure_token_for_testing' }
    admin_role AdminRole.admin
    max_people_allowed { 1000 }
  end

  factory :limited_people_allowed_admin_user, class: 'AdminUser' do
    email     { Faker::Internet.email }
    password  { 'mysecurepassword' }
    api_token { 'my_super_admin_secure_token_for_testing' }
    admin_role AdminRole.admin
    max_people_allowed { 3 }
  end
end
