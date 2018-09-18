require 'rails_helper'

RSpec.describe NaturalDocketSeed, type: :model do
  let(:invalid_seed) { described_class.new }
  let(:valid_seed)   { 
    create(:natural_docket_seed, 
      issue: create(:basic_issue),
      nationality: 'CO',
      gender: GenderKind.find_by_code('female'),
      marital_status: MaritalStatusKind.find_by_code('single')
  )}

  it 'is not valid without an issue' do
    expect(invalid_seed).to_not be_valid
  end

  it 'is valid with an issue' do
    expect(valid_seed).to be_valid
  end

  it 'create a natural docker with long accented text in job_description' do
    person = create(:empty_person)
    issue = Issue.new(person: person)
    long_seed = create(:strange_natural_docket_seed, issue: issue)
  end
end
