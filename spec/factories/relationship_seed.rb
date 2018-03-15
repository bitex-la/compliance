FactoryBot.define do
  factory :relationship_seed do
    association :related_person, factory: :another_person
    kind 'spouse' 
    association :issue, factory: :basic_issue
  end  
end
