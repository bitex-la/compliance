require 'rails_helper'

describe LegalEntityDocketSeed do
  let(:invalid_seed) { described_class.new }
  let(:valid_seed)   { 
    create(:legal_entity_docket_seed, 
      issue: create(:basic_issue),
      country: 'CO'
  )}

  %i(industry business_description country
    commercial_name legal_name
  ).each do |attr|
    it { is_expected.to strip_attribute attr }
  end

  it_behaves_like 'observable'

  it_behaves_like 'whitespaced_seed', described_class.new, {
    industry: 'Fintech  ',
    business_description: ' World domination', 
    country: ' CL',
    commercial_name: ' Crypto Soccer',
    legal_name: 'Crypto Sports Holdings  '
  }

  it_behaves_like 'person_scopable',
    create: -> (person_id) {
      issue = create(:basic_issue, person_id: person_id)
      create(:full_legal_entity_docket_seed, issue: issue)
    }

  it 'is not valid without an issue' do
    expect(invalid_seed).to_not be_valid
  end

  it 'is valid with an issue' do
    expect(valid_seed).to be_valid
  end
end
