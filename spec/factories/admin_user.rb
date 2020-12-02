FactoryBot.define do
  factory :admin_user, class: 'AdminUser' do
    email     { Faker::Internet.email }
    password  { 'mysecurepassword' }
    api_token { 'my_super_secure_token_for_testing' }
    admin_role { AdminRole.admin }
    max_people_allowed { 1000 }

    factory :operations_admin_user do
      admin_role { AdminRole.operations }
    end

    factory :commercial_admin_user do
      admin_role { AdminRole.commercial }
    end

    factory :marketing_admin_user do
      admin_role { AdminRole.marketing }
    end

    factory :compliance_admin_user do
      admin_role { AdminRole.compliance }
    end

    factory :other_admin_user do
      api_token { 'my_other_super_secure_token_for_testing' }
    end

    factory :limited_people_allowed_admin_user do
      api_token { 'my_super_admin_secure_token_for_testing' }
      max_people_allowed { 3 }
    end

    factory :admin_restricted_user do
      admin_role { AdminRole.admin_restricted }
    end
  end
end
