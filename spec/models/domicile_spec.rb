require 'rails_helper'

RSpec.describe Domicile, type: :model do
  let(:person) { create(:empty_person) } 
  let(:invalid_domicile) { described_class.new }
  let(:valid_domicile)   { create(:domicile, person: person, country: 'CO') }

  it 'is not valid without a person' do
    expect(invalid_domicile).to_not be_valid
  end

  it 'is valid with a person' do
    expect(valid_domicile).to be_valid
  end
end
