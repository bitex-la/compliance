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
end
