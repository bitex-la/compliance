FactoryBot.define do
  factory :relationship_seed do
    to   { create(:empty_person).id }
    from { create(:another_person).id }
    kind 'spouse' 
    association :issue, factory: :basic_issue
  end  
end