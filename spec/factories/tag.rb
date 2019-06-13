FactoryBot.define do
  factory :empty_tag, class: Tag do
  end

  factory :person_tag, class: Tag do
    name { 'this-is-a-person-tag-1' }
    tag_type { :person }
  end

  factory :alt_person_tag, class: Tag do
    name { 'this-is-a-person-tag-alt' }
    tag_type { :person }
  end

  factory :issue_tag, class: Tag do
    name { 'this-is-a-issue-tag-2' }
    tag_type { :issue }
  end

  factory :long_name_tag, class: Tag do
    name { 'this-is-a-issue-tag-this-is-a-issue-tag-this-is-a-issue-tag-this-is-a-issue-tag-this-is-a-issue-tag' }
    tag_type { :person }
  end

  factory :invalid_name_tag, class: Tag do
    name { 'this-is-a-issue-tag!"#$%%&/()' }
    tag_type { :person }
  end
end