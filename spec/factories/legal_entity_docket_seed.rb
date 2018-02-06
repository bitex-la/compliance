FactoryBot.define do
  factory :legal_entity_docket_seed do
    industry              'Video Games'
    business_description  'To sell AAA-rated games'
    country               'Brazil'
    commercial_name       'Awesome Games'
    legal_name            'AW S.R.L'
    association :issue, factory: :basic_issue
  end  
end