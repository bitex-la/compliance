require 'rails_helper'

describe Garden do
  it 'sets country to upper case' do
    seed = LegalEntityDocketSeed.new(
      industry: 'Fabrics',
      business_description: 'To make clothes',
      country: 'es',
      commercial_name: 'The Fabrics',
      legal_name: 'The Fabrics',
      issue: create(:basic_issue)
    )

    seed.save

    expect(seed.country).to eq('ES')
  end

  it 'sets nationality to upper case' do
    seed = NaturalDocketSeed.new(
      first_name: 'Mr Joe',
      last_name: 'Black',
      nationality: 'ar',
      job_title: ' Developer',
      job_description: 'code for food',
      issue: create(:basic_issue)
    )

    seed.save

    expect(seed.nationality).to eq('AR')
  end
end
