FactoryBot.define do
  factory :comment do
    title       'Country ID pending'
    meta        'Some meta info'
    body        'Please attach the copy of your country ID'
    author_id   1 
    association :commentable, factory: :basic_issue
  end  
end