require 'rails_helper'

RSpec.describe Allowance, type: :model do
  let(:person) {create(:empty_person)}
  let(:invalid_allowance) { described_class.new }
  let(:valid_allowance)   { create(:allowance, person: person, kind: Currency.find_by_code('ars')) }

  it 'is not valid without a person' do
    expect(invalid_allowance).to_not be_valid
  end

  it 'is valid with a person' do
    expect(valid_allowance).to be_valid
  end
end
