FactoryBot.define do
  factory :empty_tag, class: Tag do
    factory :base_person_tag do
      tag_type { :person }

      factory :person_tag do
        name { 'this-is-a-person-tag-1' }
      end

      factory :alt_person_tag do
        name { 'this-is-a-person-tag-alt' }
      end

      factory :long_name_tag do
        name { 'this-is-a-issue-tag-this-is-a-issue-tag-this-is-a-issue-tag-this-is-a-issue-tag-this-is-a-issue-tag' }
      end

      factory :invalid_name_tag do
        name { 'this-is-a-issue-tag!"#$%%&/()' }
      end
    end

    factory :base_issue_tag do
      tag_type { :issue }

      factory :issue_tag do
        name { 'this-is-a-issue-tag-2' }
      end
    end
  end
end