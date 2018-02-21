FactoryBot.define do
  factory :domicile_seed do
    factory :full_domicile_seed do
      country         'Argentina'
      state           'Buenos Aires'
      city            'C.A.B.A'
      street_address  'Cullen'
      street_number   '5229'
      postal_code     '1432'
      floor           '5'
      apartment       'A'
      association :issue, factory: :basic_issue
    end
  end  
end
  
