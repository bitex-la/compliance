FactoryBot.define do
  factory :full_admin_user_tagging, class: AdminUserTagging do
    association :admin_user, factory: :admin_user
    association :tag, factory: :person_tag
  end

  factory :invalid_type_admin_user_tagging, class: AdminUserTagging do
    association :admin_user, factory: :admin_user
    association :tag, factory: :issue_tag
  end
end
