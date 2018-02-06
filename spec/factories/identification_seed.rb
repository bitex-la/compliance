FactoryBot.define do
  factory :identification_seed do
    number '2545566'
    kind   'ID'
    issuer 'Argentina'
    association :issue, factory: :basic_issue
  end  
end
