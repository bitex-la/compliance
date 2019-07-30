require 'rails_helper'
require 'helpers/shared_examples_for_models'

RSpec.describe ChileInvoicingDetailSeed, type: :model do
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

  it 'can add observation to seed' do
    create(:human_world_check_reason)
    valid_seed = create(:full_chile_invoicing_detail_seed_with_issue)
    expect do
      obs = valid_seed.observations.build()
      obs.observation_reason = ObservationReason.first
      obs.scope = :admin
      valid_seed.save!  
    end.to change{ valid_seed.observations.count }.by(1)

    first = valid_seed.observations.first 
    expect(first.observation_reason).to eq(ObservationReason.first)
    expect(first.scope).to eq("admin")
    expect(first.observable).to eq(valid_seed)
  end
end