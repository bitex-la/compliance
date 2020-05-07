FactoryBot.define do
  factory :admin_user_tagging do
    factory :full_admin_user_tagging do
      association :admin_user, factory: :admin_user
      association :tag, factory: :person_tag
    end

    factory :invalid_type_admin_user_tagging do
      association :admin_user, factory: :admin_user
      association :tag, factory: :issue_tag
    end

    factory :admin_tagging_to_apply_rules do
      association :tag, factory: :person_tag, name: 'tagging-enabled'
    end
  end
end
