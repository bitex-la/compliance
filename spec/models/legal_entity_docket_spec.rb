require 'rails_helper'

RSpec.describe LegalEntityDocket, type: :model do
  let(:person) { create(:empty_person) }
  let(:invalid_docket) { described_class.new }
  let(:valid_docket)   { create(:legal_entity_docket, person: person) }

  it 'is not valid without a person' do
    expect(invalid_docket).to_not be_valid
  end

  it 'is valid with a person' do
    expect(valid_docket).to be_valid
  end
end
