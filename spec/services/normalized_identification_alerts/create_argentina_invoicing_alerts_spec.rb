require 'rails_helper'

describe NormalizedIdentificationAlerts::CreateArgentinaInvoicingAlerts do
  
  before :each do
    @first_person = create(:empty_person)
    first_issue = create(:basic_issue, person: @first_person)
    first_seed = ArgentinaInvoicingDetailSeed.create(
      vat_status_code: 'monotributo',
      tax_id: '20345791575',
      tax_id_kind_code: TaxIdKind.cuit.code,
      receipt_kind_code: 'a',
      full_name: 'Hugo Gallotto',
      address: 'Cordoba',
      country: 'ar',
      issue: first_issue
    )
    first_issue.complete!
    first_issue.reload
  end

  it 'Finds duplicates tax_id on invoicing and creates alerts' do
    second_person = create(:empty_person)
    second_issue = create(:basic_issue, person: second_person)
    second_seed = ArgentinaInvoicingDetailSeed.create(
      vat_status_code: 'monotributo',
      tax_id: '20-34.579.157-5',
      tax_id_kind_code: TaxIdKind.cuil.code,
      receipt_kind_code: 'a',
      full_name: 'Jeff bezos',
      address: 'Cordoba',
      country: 'ar',
      issue: second_issue
    )
    second_issue.complete!
    second_issue.reload
    
    expect(second_issue.risk_score_seeds.count).to eq(1)
    expect(second_issue.risk_score_seeds.first.issue_id).to eq(second_issue.id)
    expect(second_issue.risk_score_seeds.first.score).to eq('High')
    expect(second_issue.risk_score_seeds.first.provider).to eq('Compliance Legacy')
    expect(second_issue.risk_score_seeds.first.extra_info).to eq('El TAX ID ingresado por el usuario ya se encuentra registrado')
    expect(second_issue.risk_score_seeds.first.external_link).to eq("/people/#{@first_person.id}")
    
    expect(second_issue.affinity_seeds.count).to eq(1)
    expect(second_issue.affinity_seeds.first.issue_id).to eq(second_issue.id)
    expect(second_issue.affinity_seeds.first.affinity_kind_id).to eq(AffinityKind.compliance_liaison.id)
    expect(second_issue.affinity_seeds.first.related_person_id).to eq(@first_person.id)
  end

  it 'Finds duplicates tax_id on invoicings and identifications' do
    identification_person = create(:empty_person)
    identification_issue = create(:basic_issue, person: identification_person)
    identification_seed = IdentificationSeed.create(
      identification_kind_id: IdentificationKind.tax_id.id,
      number: '20-345791-575A',
      issuer: 'AR',
      issue: identification_issue
    )
    identification_issue.complete!
    identification_issue.reload

    invoicing_person = create(:empty_person)
    invoicing_issue = create(:basic_issue, person: invoicing_person)
    invoicing_seed = ArgentinaInvoicingDetailSeed.create(
      vat_status_code: 'monotributo',
      tax_id: 'A2034579.157-5U',
      tax_id_kind_code: TaxIdKind.cuit.code,
      receipt_kind_code: 'a',
      full_name: 'Mark',
      address: 'Cordoba',
      country: 'ar',
      issue: invoicing_issue
    )
    invoicing_issue.complete!
    invoicing_issue.reload

    expect(invoicing_issue.risk_score_seeds.count).to eq(1)
    expect(invoicing_issue.risk_score_seeds.first.issue_id).to eq(invoicing_issue.id)
    expect(invoicing_issue.affinity_seeds.count).to eq(2)
  end
end
