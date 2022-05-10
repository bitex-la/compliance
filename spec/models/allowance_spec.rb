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

  it 'update person ipt' do
    expect(person.ipt).to eq 'usd_0'
    create(:allowance, person: person, kind: Currency.find_by_code('ars'), ipt: 2)
    expect(person.ipt).to eq 'usd_10000_to_20000'
    create(:allowance, person: person, kind: Currency.find_by_code('ars'), ipt: 4)
    expect(person.ipt).to eq 'usd_50000_to_100000'
  end
end
