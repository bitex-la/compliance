require 'rails_helper'
require 'helpers/shared_examples_for_models'

RSpec.describe DomicileSeed, type: :model do
  let(:invalid_seed) { described_class.new }
  let(:valid_seed)   { 
    create(:domicile_seed, 
      issue: create(:basic_issue),
      country: 'CO'
  )}

  it_behaves_like 'observable'

  it_behaves_like 'archived_seed', :full_domicile

  %i(country state city street_address street_number
    postal_code floor apartment
  ).each do |attr|
    it { is_expected.to strip_attribute attr }
  end

  it_behaves_like 'whitespaced_seed', described_class.new, {
    country: ' AR',
    state: 'Buenos Aires  ',
    city: '  C.A.B.A   ',
    street_address: '    Cullen',
    street_number: '5229 ',
    postal_code: ' 1432 ',
    floor: ' 5 ',
    apartment: 'A '
  }

  it_behaves_like 'person_scopable',
    create: -> (person_id) {
      issue = create(:basic_issue, person_id: person_id)
      create(:full_domicile_seed, issue: issue)
    }

  it_behaves_like 'model_validations', described_class

  it 'is not valid without an issue' do
    expect(invalid_seed).to_not be_valid
  end

  it 'is valid with an issue' do
    expect(valid_seed).to be_valid
  end

  it 'is valid with AN country' do
    domicile = create(:domicile_seed, issue: create(:basic_issue),
      country: 'AN')
    expect(domicile).to be_valid
  end

  it 'sets country to upper case' do
    seed = DomicileSeed.new(
      country: 'ar',
      state: 'Buenos Aires',
      city: 'C.A.B.A',
      street_address: 'Cullen',
      street_number: '5229',
      postal_code: '1432',
      floor: '5',
      apartment: 'A',
      issue: create(:basic_issue)
    )

    seed.save

    expect(seed.country).to eq('AR')
  end
end
