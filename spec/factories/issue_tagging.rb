FactoryBot.define do
  factory :issue_tagging do
    factory :full_issue_tagging do
      association :issue, factory: :basic_issue
      association :tag, factory: :issue_tag

      factory :some_issue_tagging do
        association :tag, factory: :some_issue_tag
      end
    end

    factory :invalid_type_issue_tagging do
      association :issue, factory: :basic_issue
      association :tag, factory: :person_tag
    end
  end
end
