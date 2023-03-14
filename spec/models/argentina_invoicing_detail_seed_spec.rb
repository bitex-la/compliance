require 'rails_helper'

describe ArgentinaInvoicingDetailSeed do
  %i(tax_id full_name address country).each do |attr|
    it { is_expected.to strip_attribute attr }
  end

  it_behaves_like 'whitespaced_seed', described_class.new, {
    vat_status_code: :monotributo,
    tax_id: ' 20955754290',
    tax_id_kind_code: :cuit,
    receipt_kind_code: :a,
    full_name: 'Luis Miguel   ',
    address: '   Jujuy 3421',
    country: 'AR '
  }

  it_behaves_like 'observable', :full_argentina_invoicing_detail_seed_with_issue

  it_behaves_like 'person_scopable',
    create: -> (person_id) {
      issue = create(:basic_issue, person_id: person_id)
      create(:full_argentina_invoicing_detail_seed, issue: issue)
    }

  it_behaves_like 'model_validations', described_class

  it 'sets country to upper case' do
    seed = ArgentinaInvoicingDetailSeed.new(
      vat_status_code: 'monotributo',
      tax_id: '20955754290',
      tax_id_kind_code: 'cuit',
      receipt_kind_code: 'a',
      full_name: 'Julio Iglesias',
      address: 'Jujuy 3421',
      country: 'ar',
      issue: create(:basic_issue)
    )

    seed.save

    expect(seed.country).to eq('AR')
  end

  describe 'normalize_tax_id' do
    it 'receives tax id with the correct conditions and returns tax id normalized' do 
      seed = ArgentinaInvoicingDetailSeed.new(
        vat_status_code: 'monotributo',
        tax_id: '20-34.579.157-5',
        tax_id_kind_code: 'cuit',
        receipt_kind_code: 'a',
        full_name: 'Julio Iglesias',
        address: 'Jujuy 3421',
        country: 'ar',
        issue: create(:basic_issue)
      )
      expect(seed.normalize_tax_id).to eq('20345791575')
    end

    it 'receives tax id without the right conditions and return nil' do 
      seed = ArgentinaInvoicingDetailSeed.new(
        vat_status_code: 'monotributo',
        tax_id: 'abcdefg',
        tax_id_kind_code: 'cuit',
        receipt_kind_code: 'a',
        full_name: 'Julio Iglesias',
        address: 'Jujuy 3421',
        country: 'ar',
        issue: create(:basic_issue)
      )
      expect(seed.normalize_tax_id).to eq(nil)
    end
  end
end
