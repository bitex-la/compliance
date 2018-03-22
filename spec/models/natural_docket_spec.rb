require 'rails_helper'

RSpec.describe NaturalDocket, type: :model do
  let(:person) { create(:empty_person) }
  let(:invalid_docket) { described_class.new }
  let(:valid_docket)   { 
    create(:natural_docket, 
      person: person,
      nationality: 'CO',
      gender: GenderKind.find(1).id,
      marital_status: MaritalStatusKind.find(1).id
  )}

  it 'is not valid without a person' do
    expect(invalid_docket).to_not be_valid
  end

  it 'is valid with a person' do
    expect(valid_docket).to be_valid
  end
end
