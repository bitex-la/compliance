require 'rails_helper'

describe Allowance do
  let(:person) {create(:empty_person)}
  let(:invalid_allowance) { described_class.new }
  let(:valid_allowance)   { create(:allowance, person: person, kind: Currency.find_by_code('ars')) }

  it_behaves_like 'archived_fruit', :allowances, :salary_allowance

  it_behaves_like 'person_scopable_fruit', :salary_allowance

  it 'is not valid without a person' do
    expect(invalid_allowance).to_not be_valid
  end

  it 'is valid with a person' do
    expect(valid_allowance).to be_valid
  end

  it 'update person tpi' do
    expect(person.tpi).to eq 'unknown'
    create(:allowance, person: person, kind: Currency.find_by_code('ars'), tpi: 2)
    expect(person.tpi).to eq 'usd_5001_to_10000'
    create(:allowance, person: person, kind: Currency.find_by_code('ars'), tpi: 4)
    expect(person.tpi).to eq 'usd_20001_to_50000'
  end

  it 'does not update person tpi' do
    expect(person.tpi).to eq 'unknown'
    create(:allowance, person: person, kind: Currency.find_by_code('ars'), tpi: nil)
    expect(person.tpi).to eq 'unknown'
  end
end
