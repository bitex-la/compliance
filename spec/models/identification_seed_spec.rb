require 'rails_helper'

describe IdentificationSeed do
  let(:invalid_seed) { described_class.new }
  let(:valid_seed)   { 
    create(:identification_seed, 
      identification_kind: IdentificationKind.find_by_code('national_id'),
      issuer: 'CO'
  )}

  it_behaves_like 'observable'

  it_behaves_like 'archived_seed', :full_natural_person_identification

  %i(number issuer public_registry_authority 
  public_registry_book public_registry_extra_data).each do |attr|
    it { is_expected.to strip_attribute attr }
  end

  it_behaves_like 'whitespaced_seed', described_class.new, {
    number: '20955794280  ',
    issuer: 'AR ',
    identification_kind_code: :tax_id,
    public_registry_authority: ' AFIP ' ,
    public_registry_book: ' 23456 ',
    public_registry_extra_data: ' 344343'
  }

  it_behaves_like 'person_scopable',
    create: -> (person_id) {
      issue = create(:basic_issue, person_id: person_id)
      create(:full_natural_person_identification_seed, issue: issue)
    }

  it_behaves_like 'model_validations', described_class

  it 'is not valid without an issue' do
    expect(invalid_seed).to_not be_valid
  end

  it 'is valid with an issue' do
    expect(valid_seed).to be_valid
  end

  it 'sets issuer to upper case' do
    seed = IdentificationSeed.new(
      number: '2545566',
      identification_kind_code: 'national_id',
      issuer: 'mx',
      issue: create(:basic_issue)
    )

    seed.save

    expect(seed.issuer).to eq('MX')
  end

  describe 'Chile normalize_number' do
    it 'receives number with the correct conditions and returns tax id normalized' do 
      seed = IdentificationSeed.create(
        identification_kind_id: IdentificationKind.national_id.id,
        number: '12.3456.789-K',
        issuer: 'CL',
        issue: create(:basic_issue)
      )
      expect(seed.number_normalized).to eq('123456789K')
    end

    it 'receives tax id without the right conditions and return nil' do 
      seed = IdentificationSeed.create(
        identification_kind_id: IdentificationKind.national_id.id,
        number: 'abcdef',
        issuer: 'CL',
        issue: create(:basic_issue)
      )
      expect(seed.number_normalized).to eq(nil)
    end
  end

  describe 'Argentina normalize_number' do
    it 'receives number with the correct conditions and returns tax id normalized' do 
      seed = IdentificationSeed.create(
        identification_kind_id: IdentificationKind.national_id.id,
        number: '34.579.157',
        issuer: 'AR',
        issue: create(:basic_issue)
      )
      expect(seed.number_normalized).to eq('34579157')
    end

    it 'receives tax id without the right conditions and return nil' do 
      seed = IdentificationSeed.create(
        identification_kind_id: IdentificationKind.national_id.id,
        number: 'abcdef',
        issuer: 'AR',
        issue: create(:basic_issue)
      )
      expect(seed.number_normalized).to eq(nil)
    end
  end
end
