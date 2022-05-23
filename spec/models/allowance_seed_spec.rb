require 'rails_helper'

describe AllowanceSeed do

  let(:invalid_seed) { described_class.new }
  let(:valid_seed)   { create(:salary_allowance_seed, issue: create(:basic_issue)) }

  it_behaves_like 'observable'

  it_behaves_like 'person_scopable',
    create: -> (person_id) {
      issue = create(:basic_issue, person_id: person_id)
      create(:salary_allowance_seed, issue: issue)
    }

  it_behaves_like 'archived_seed', :salary_allowance

  it_behaves_like 'model_validations', described_class

  it 'is not valid without an issue' do
    expect(invalid_seed).to_not be_valid
  end

  it 'is valid with an issue' do
    expect(valid_seed).to be_valid
  end

  describe '#update person tpi' do
    let(:person) {create(:empty_person)}

    it 'update person tpi' do
      expect(person.tpi).to eq 'unknown'
      create(:salary_allowance_seed, issue: create(:basic_issue), tpi: 2, person: person)
      expect(person.tpi).to eq 'usd_5001_to_10000'
      create(:salary_allowance_seed, issue: create(:basic_issue), tpi: 4, person: person)
      expect(person.tpi).to eq 'usd_20001_to_50000'
    end

    it 'does not update person tpi' do
      expect(person.tpi).to eq 'unknown'
      create(:salary_allowance_seed, issue: create(:basic_issue), tpi: nil)
      expect(person.tpi).to eq 'unknown'
    end
  end
end
