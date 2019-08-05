FactoryBot.define do
  factory :full_issue_tagging, class: IssueTagging do
    association :issue, factory: :basic_issue
    association :tag, factory: :issue_tag
  end

  factory :invalid_type_issue_tagging, class: IssueTagging do
    association :issue, factory: :basic_issue
    association :tag, factory: :person_tag
  end
end