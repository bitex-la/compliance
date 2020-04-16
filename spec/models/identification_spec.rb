require 'rails_helper'

RSpec.describe Identification, type: :model do
  let(:person) { create(:empty_person) }
  let(:invalid_identification) { described_class.new }
  let(:valid_identification)   { 
    create(:identification, 
      person: person,
      identification_kind: IdentificationKind.find_by_code('national_id'),
      issuer: 'CO'
  )}

  it_behaves_like 'archived_fruit', :identifications, :full_natural_person_identification

  it 'is not valid without a person' do
    expect(invalid_identification).to_not be_valid
  end

  it 'is valid with a person' do
    expect(valid_identification).to be_valid
  end
end
