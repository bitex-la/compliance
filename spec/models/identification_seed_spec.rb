require 'rails_helper'
require 'helpers/shared_examples_for_models'

RSpec.describe IdentificationSeed, type: :model do
  let(:invalid_seed) { described_class.new }
  let(:valid_seed)   { 
    create(:identification_seed, 
      identification_kind: IdentificationKind.find_by_code('national_id'),
      issuer: 'CO'
  )}

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

  it 'is not valid without an issue' do
    expect(invalid_seed).to_not be_valid
  end

  it 'is valid with an issue' do
    expect(valid_seed).to be_valid
  end
end
