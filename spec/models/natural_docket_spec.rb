require 'rails_helper'

RSpec.describe NaturalDocket, type: :model do
  let(:person) { create(:empty_person) }
  let(:invalid_docket) { described_class.new }
  let(:valid_docket)   { 
    create(:natural_docket, 
      person: person,
      nationality: 'CO',
      gender: GenderKind.find_by_code('female'),
      marital_status: MaritalStatusKind.find_by_code('single')
  )}

  it 'is not valid without a person' do
    expect(invalid_docket).to_not be_valid
  end

  it 'is valid with a person' do
    expect(valid_docket).to be_valid
  end

  it 'serializes empty natural docket' do
    expect do
      NaturalDocketSerializer.new(NaturalDocket.new).serialized_json
    end.not_to raise_exception
  end
end
