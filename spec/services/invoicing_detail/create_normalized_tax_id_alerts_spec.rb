require 'rails_helper'

describe ArgentinaInvoicingDetailSeed do
  it 'Find duplicates normalized Argentina tax_id and creates alerts' do
    first_person = create(:empty_person)
    first_issue = create(:basic_issue, person: first_person)
    first_seed = ArgentinaInvoicingDetailSeed.create(
      vat_status_code: 'monotributo',
      tax_id: '20345791575',
      tax_id_kind_code: 'cuit',
      receipt_kind_code: 'a',
      full_name: 'Hugo Gallotto',
      address: 'Cordoba',
      country: 'ar',
      issue: first_issue
    )
    first_issue.complete!

    second_person = create(:empty_person)
    second_issue = create(:basic_issue, person: second_person)
    second_seed = ArgentinaInvoicingDetailSeed.create(
      vat_status_code: 'monotributo',
      tax_id: '20-34.579.157-5',
      tax_id_kind_code: 'cuit',
      receipt_kind_code: 'a',
      full_name: 'Jeff bezos',
      address: 'Cordoba',
      country: 'ar',
      issue: second_issue
    )
    second_issue.complete!
    second_issue.reload
    
    expect(first_issue.risk_score_seeds.count).to eq(0)
    expect(first_issue.affinity_seeds.count).to eq(0)
    
    expect(second_issue.risk_score_seeds.count).to eq(1)
    expect(second_issue.risk_score_seeds.first.issue_id).to eq(second_issue.id)
    expect(second_issue.risk_score_seeds.first.score).to eq('High')
    expect(second_issue.risk_score_seeds.first.provider).to eq('Compliance Legacy')
    expect(second_issue.risk_score_seeds.first.extra_info).to eq('El TAX ID ingresado por el usuario ya se encuentra registrado')
    expect(second_issue.risk_score_seeds.first.external_link).to eq("/people/#{first_person.id}")
    
    expect(second_issue.affinity_seeds.count).to eq(1)
    expect(second_issue.affinity_seeds.first.issue_id).to eq(second_issue.id)
    expect(second_issue.affinity_seeds.first.affinity_kind_id).to eq(AffinityKind.compliance_liaison.id)
    expect(second_issue.affinity_seeds.first.related_person_id).to eq(first_person.id)

    third_person = create(:empty_person)
    third_issue = create(:basic_issue, person: third_person)
    third_seed = ArgentinaInvoicingDetailSeed.create(
      vat_status_code: 'monotributo',
      tax_id: 'AB2034579.157-5U',
      tax_id_kind_code: 'cuit',
      receipt_kind_code: 'a',
      full_name: 'Mark',
      address: 'Cordoba',
      country: 'ar',
      issue: third_issue
    )
    third_issue.complete!
    third_issue.reload

    expect(third_issue.risk_score_seeds.count).to eq(1)
    expect(third_issue.affinity_seeds.count).to eq(2)
  end

  it 'Receives nil tax_id and does not create alerts' do
    first_person = create(:empty_person)
    first_issue = create(:basic_issue, person: first_person)
    first_seed = ArgentinaInvoicingDetailSeed.create(
      vat_status_code: 'monotributo',
      tax_id: nil,
      tax_id_kind_code: 'cuit',
      receipt_kind_code: 'a',
      full_name: 'Hugo Gallotto',
      address: 'Cordoba',
      country: 'ar',
      issue: first_issue
    )
    first_issue.complete!
    first_issue.reload

    second_person = create(:empty_person)
    second_issue = create(:basic_issue, person: second_person)
    second_seed = ArgentinaInvoicingDetailSeed.create(
      vat_status_code: 'monotributo',
      tax_id: nil,
      tax_id_kind_code: 'cuit',
      receipt_kind_code: 'a',
      full_name: 'Jeff bezos',
      address: 'Cordoba',
      country: 'ar',
      issue: second_issue
    )
    second_issue.complete!
    second_issue.reload

    expect(second_issue.risk_score_seeds.count).to eq(0)
    expect(second_issue.affinity_seeds.count).to eq(0)
  end

  it 'Receives invalid string from tax_id and does not create alerts' do
    first_person = create(:empty_person)
    first_issue = create(:basic_issue, person: first_person)
    first_seed = ArgentinaInvoicingDetailSeed.create(
      vat_status_code: 'monotributo',
      tax_id: 'asdasfsdfds',
      tax_id_kind_code: 'cuit',
      receipt_kind_code: 'a',
      full_name: 'Hugo Gallotto',
      address: 'Cordoba',
      country: 'ar',
      issue: first_issue
    )
    first_issue.complete!
    first_issue.reload

    second_person = create(:empty_person)
    second_issue = create(:basic_issue, person: second_person)
    second_seed = ArgentinaInvoicingDetailSeed.create(
      vat_status_code: 'monotributo',
      tax_id: 'jhhjjjjjjjj',
      tax_id_kind_code: 'cuit',
      receipt_kind_code: 'a',
      full_name: 'Jeff bezos',
      address: 'Cordoba',
      country: 'ar',
      issue: second_issue
    )
    second_issue.complete!
    second_issue.reload

    expect(second_issue.risk_score_seeds.count).to eq(0)
    expect(second_issue.affinity_seeds.count).to eq(0)
  end
end

describe ChileInvoicingDetailSeed do
  it 'Find duplicates normalized Chile tax_id and creates alerts' do
    first_person = create(:empty_person)
    first_issue = create(:basic_issue, person: first_person)
    first_seed = ChileInvoicingDetailSeed.create(
      tax_id: '123456789K',
      giro: 'Venta de Electrodomesticos  ',
      ciudad: 'Santiago',
      comuna: 'Las condes',
      vat_status_code: :inscripto,
      issue: first_issue,
    )
    first_issue.complete!
    first_issue.reload

    second_person = create(:empty_person)
    second_issue = create(:basic_issue, person: second_person)
    second_seed = ChileInvoicingDetailSeed.create(
      tax_id: 'A12.345.678-9K',
      giro: 'Venta de Electrodomesticos',
      ciudad: 'Juan',
      comuna: 'Las condes',
      vat_status_code: :inscripto,
      issue: second_issue
    )
    second_issue.complete!
    second_issue.reload
    
    expect(first_issue.risk_score_seeds.count).to eq(0)
    expect(first_issue.affinity_seeds.count).to eq(0)
    
    expect(second_issue.risk_score_seeds.count).to eq(1)
    expect(second_issue.risk_score_seeds.first.issue_id).to eq(second_issue.id)
    expect(second_issue.risk_score_seeds.first.score).to eq('High')
    expect(second_issue.risk_score_seeds.first.provider).to eq('Compliance Legacy')
    expect(second_issue.risk_score_seeds.first.extra_info).to eq('El TAX ID ingresado por el usuario ya se encuentra registrado')
    expect(second_issue.risk_score_seeds.first.external_link).to eq("/people/#{first_person.id}")
    
    expect(second_issue.affinity_seeds.count).to eq(1)
    expect(second_issue.affinity_seeds.first.issue_id).to eq(second_issue.id)
    expect(second_issue.affinity_seeds.first.affinity_kind_id).to eq(AffinityKind.compliance_liaison.id)
    expect(second_issue.affinity_seeds.first.related_person_id).to eq(first_person.id)

    third_person = create(:empty_person)
    third_issue = create(:basic_issue, person: third_person)
    third_seed = ChileInvoicingDetailSeed.create(
      tax_id: 'A12.3456789K',
      giro: 'Venta de Cosméticos',
      ciudad: 'Juan',
      comuna: 'Las Granadas',
      vat_status_code: :inscripto,
      issue: third_issue
    )
    third_issue.complete!
    third_issue.reload
    
    expect(third_issue.risk_score_seeds.count).to eq(1)
    expect(third_issue.affinity_seeds.count).to eq(2)
  end

  it 'Receives invalid string to tax_id and does not create alerts' do
    first_person = create(:empty_person)
    first_issue = create(:basic_issue, person: first_person)
    first_seed = ChileInvoicingDetailSeed.create(
      tax_id: nil,
      giro: 'Venta de Electrodomesticos  ',
      ciudad: 'Santiago',
      comuna: 'Las condes',
      vat_status_code: :inscripto,
      issue: first_issue,
    )
    first_issue.complete!
    first_issue.reload

    second_person = create(:empty_person)
    second_issue = create(:basic_issue, person: second_person)
    second_seed = ChileInvoicingDetailSeed.create(
      tax_id: nil,
      giro: 'Venta de Electrodomesticos',
      ciudad: 'Juan',
      comuna: 'Las condes',
      vat_status_code: :inscripto,
      issue: second_issue
    )
    second_issue.complete!
    second_issue.reload
    
    expect(second_issue.risk_score_seeds.count).to eq(0)
    expect(second_issue.affinity_seeds.count).to eq(0)
  end

  it 'Receives invalid string from tax_id and does not create alerts' do
    first_person = create(:empty_person)
    first_issue = create(:basic_issue, person: first_person)
    first_seed = ChileInvoicingDetailSeed.create(
      tax_id: 'qweasdqwe',
      giro: 'Venta de Electrodomesticos  ',
      ciudad: 'Santiago',
      comuna: 'Las condes',
      vat_status_code: :inscripto,
      issue: first_issue,
    )
    first_issue.complete!
    first_issue.reload

    second_person = create(:empty_person)
    second_issue = create(:basic_issue, person: second_person)
    second_seed = ChileInvoicingDetailSeed.create(
      tax_id: 'poipoipoi',
      giro: 'Venta de Electrodomesticos',
      ciudad: 'Juan',
      comuna: 'Las condes',
      vat_status_code: :inscripto,
      issue: second_issue
    )
    second_issue.complete!
    second_issue.reload
    
    expect(second_issue.risk_score_seeds.count).to eq(0)
    expect(second_issue.affinity_seeds.count).to eq(0)
  end
end
