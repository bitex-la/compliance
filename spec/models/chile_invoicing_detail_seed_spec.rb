require 'rails_helper'

describe ChileInvoicingDetailSeed do
  %i(tax_id giro ciudad comuna).each do |attr|
    it { is_expected.to strip_attribute attr }
  end

  it_behaves_like 'whitespaced_seed', described_class.new, {
    tax_id: ' 10569670-1 ',
    giro: 'Venta de Electrodomesticos  ',
    ciudad: 'Santiago',
    comuna: 'Las condes',
    vat_status_code: :inscripto
  }

  it_behaves_like 'observable', :full_chile_invoicing_detail_seed_with_issue

  it_behaves_like 'person_scopable',
    create: -> (person_id) {
      issue = create(:basic_issue, person_id: person_id)
      create(:full_chile_invoicing_detail_seed, issue: issue)
    }

  it_behaves_like 'model_validations', described_class

  describe 'normalize_tax_id' do
    it 'receives tax id with the correct conditions and returns tax id normalized' do 
      seed = ChileInvoicingDetailSeed.new(
        tax_id: '12-345.678.9-K!',
        giro: 'Venta de Electrodomesticos',
        ciudad: 'Santiago',
        comuna: 'Las condes',
        vat_status_code: :inscripto,
      )
      expect(seed.normalize_tax_id).to eq('123456789K')
    end

    it 'receives tax id without the right conditions and return nil' do 
      seed = ChileInvoicingDetailSeed.new(
        tax_id: 'abcdef',
        giro: 'Venta de Electrodomesticos',
        ciudad: 'Santiago',
        comuna: 'Las condes',
        vat_status_code: :inscripto,
      )
      expect(seed.normalize_tax_id).to eq(nil)
    end
  end
end
