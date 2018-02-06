FactoryBot.define do
  factory :natural_docket_seed do
    first_name     'Joe'
    last_name      'Doe'
    birth_date     Date.today
    nationality    'Argentina'
    gender         'Male'
    marital_status 'Single'
    association :issue, factory: :basic_issue
  end  
end