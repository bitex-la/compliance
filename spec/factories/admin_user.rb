FactoryBot.define do
  factory :admin_user, class: 'AdminUser' do
    email     { Faker::Internet.email }
    password  { 'mysecurepassword' }
    api_token { 'my_super_secure_token_for_testing' }
    admin_role AdminRole.admin
    max_people_allowed { 1000 }

    factory :operations_admin_user do
      admin_role AdminRole.operations
    end

    factory :commercial_admin_user do
      admin_role AdminRole.commercial
    end

    factory :marketing_admin_user do
      admin_role AdminRole.marketing
    end
  end

  factory :other_admin_user, class: 'AdminUser' do
    email     { Faker::Internet.email }
    password  { 'mysecurepassword' }
    api_token { 'my_other_super_secure_token_for_testing' }
    admin_role AdminRole.admin
    max_people_allowed { 1000 }
  end

  factory :compliance_admin_user, class: 'AdminUser' do
    email     { Faker::Internet.email }
    password  { 'myrestrictedpassword' }
    api_token { 'my_restricted_token_for_testing' }
    admin_role AdminRole.compliance
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
