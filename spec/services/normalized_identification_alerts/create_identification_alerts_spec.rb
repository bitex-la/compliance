require 'rails_helper'

describe NormalizedIdentificationAlerts::CreateIdentificationAlerts do
  describe 'Search by tax_id' do 
    it 'finds duplicates Argentina tax_id on identifications and invoicing and then creates alerts' do
      invoicing_person = create(:empty_person)
      invoicing_issue = create(:basic_issue, person: invoicing_person)
      invoicing_seed = ArgentinaInvoicingDetailSeed.create(
        vat_status_code: 'monotributo',
        tax_id: '20-34579157-5',
        tax_id_kind_code: TaxIdKind.cuit.code,
        receipt_kind_code: 'a',
        full_name: 'Jeff bezos',
        address: 'Cordoba',
        country: 'ar',
        issue: invoicing_issue
      )
      invoicing_issue.complete!
      invoicing_issue.reload

      identification_person = create(:empty_person)
      identification_issue = create(:basic_issue, person: identification_person)
      identification_seed = IdentificationSeed.create(
        identification_kind_id: IdentificationKind.tax_id.id,
        number: '20345791575',
        issuer: 'AR',
        issue_id: identification_issue.id
      )
      identification_issue.reload
      identification_issue.complete!
      identification_issue.reload

      duplicate_person = create(:empty_person)
      duplicate_issue = create(:basic_issue, person: duplicate_person)
      duplicate_seed = IdentificationSeed.create(
        identification_kind_id: IdentificationKind.tax_id.id,
        number: '20.34.579.157.5',
        issuer: 'AR',
        issue_id: duplicate_issue.id
      )
      duplicate_issue.reload
      duplicate_issue.complete!
      duplicate_issue.reload

      expect(duplicate_issue.risk_score_seeds.count).to eq(1)
      expect(duplicate_issue.risk_score_seeds.first.issue_id).to eq(duplicate_issue.id)
      expect(duplicate_issue.risk_score_seeds.first.score).to eq('High')
      expect(duplicate_issue.risk_score_seeds.first.provider).to eq('Compliance Legacy')
      expect(duplicate_issue.risk_score_seeds.first.extra_info).to eq('El TAX ID ingresado por el usuario ya se encuentra registrado')
      
      expect(duplicate_issue.affinity_seeds.count).to eq(2)
      expect(duplicate_issue.affinity_seeds.first.issue_id).to eq(duplicate_issue.id)
      expect(duplicate_issue.affinity_seeds.first.affinity_kind_id).to eq(AffinityKind.compliance_liaison.id)
      expect(duplicate_issue.affinity_seeds.first.related_person_id).to eq(invoicing_person.id)

      expect(duplicate_issue.affinity_seeds.second.issue_id).to eq(duplicate_issue.id)
      expect(duplicate_issue.affinity_seeds.second.affinity_kind_id).to eq(AffinityKind.compliance_liaison.id)
      expect(duplicate_issue.affinity_seeds.second.related_person_id).to eq(identification_person.id)
    end

    it 'Finds duplicates Chile tax_id on identifications and invoicing and then creates alerts' do
      invoicing_person = create(:empty_person)
      invoicing_issue = create(:basic_issue, person: invoicing_person)
      invoicing_seed = ChileInvoicingDetailSeed.create(
        tax_id: '123456789K',
        giro: 'Venta de Electrodomesticos  ',
        ciudad: 'Santiago',
        comuna: 'Las condes',
        vat_status_code: :inscripto,
        issue: invoicing_issue,
      )
      invoicing_issue.complete!
      invoicing_issue.reload
  
      identification_person = create(:empty_person)
      identification_issue = create(:basic_issue, person: identification_person)
      identification_seed = IdentificationSeed.create(
        identification_kind_id: IdentificationKind.tax_id.id,
        number: '12.3456.789-K',
        issuer: 'CL',
        issue_id: identification_issue.id
      )
      identification_issue.reload
      identification_issue.complete!
  
      duplicate_person = create(:empty_person)
      duplicate_issue = create(:basic_issue, person: duplicate_person)
      duplicate_seed = IdentificationSeed.create(
        identification_kind_id: IdentificationKind.tax_id.id,
        number: '12-3456-789K',
        issuer: 'CL',
        issue_id: duplicate_issue.id
      )
      duplicate_issue.reload
      duplicate_issue.complete!
  
      duplicate_issue.reload
      expect(duplicate_issue.risk_score_seeds.count).to eq(1)
      expect(duplicate_issue.risk_score_seeds.first.issue_id).to eq(duplicate_issue.id)
      expect(duplicate_issue.risk_score_seeds.first.score).to eq('High')
      expect(duplicate_issue.risk_score_seeds.first.provider).to eq('Compliance Legacy')
      expect(duplicate_issue.risk_score_seeds.first.extra_info).to eq('El TAX ID ingresado por el usuario ya se encuentra registrado')
      
      expect(duplicate_issue.affinity_seeds.count).to eq(2)
      expect(duplicate_issue.affinity_seeds.first.issue_id).to eq(duplicate_issue.id)
      expect(duplicate_issue.affinity_seeds.first.affinity_kind_id).to eq(AffinityKind.compliance_liaison.id)
      expect(duplicate_issue.affinity_seeds.first.related_person_id).to eq(invoicing_person.id)
  
      expect(duplicate_issue.affinity_seeds.second.issue_id).to eq(duplicate_issue.id)
      expect(duplicate_issue.affinity_seeds.second.affinity_kind_id).to eq(AffinityKind.compliance_liaison.id)
      expect(duplicate_issue.affinity_seeds.second.related_person_id).to eq(identification_person.id)
    end
  end

  describe 'Search by national_id' do
    it 'Finds duplicates Argentina national_id on identifications and invoicing and then creates alerts' do
      invoicing_person = create(:empty_person)
      invoicing_issue = create(:basic_issue, person: invoicing_person)
      invoicing_seed = ArgentinaInvoicingDetailSeed.create(
        vat_status_code: 'monotributo',
        tax_id: '34579157',
        tax_id_kind_code: TaxIdKind.dni.code,
        receipt_kind_code: 'a',
        full_name: 'Jeff bezos',
        address: 'Cordoba',
        country: 'ar',
        issue: invoicing_issue
      )
      invoicing_issue.complete!
      invoicing_issue.reload
  
      identification_person = create(:empty_person)
      identification_issue = create(:basic_issue, person: identification_person)
      identification_seed = IdentificationSeed.create(
        identification_kind_id: IdentificationKind.national_id.id,
        number: '34.579.157',
        issuer: 'AR',
        issue_id: identification_issue.id
      )
      identification_issue.reload
      identification_issue.complete!
  
      duplicate_person = create(:empty_person)
      duplicate_issue = create(:basic_issue, person: duplicate_person)
      duplicate_seed = IdentificationSeed.create(
        identification_kind_id: IdentificationKind.national_id.id,
        number: '34-579-157',
        issuer: 'AR',
        issue_id: duplicate_issue.id
      )
      duplicate_issue.reload
      duplicate_issue.complete!
      
      duplicate_issue.reload
      expect(duplicate_issue.risk_score_seeds.count).to eq(1)
      expect(duplicate_issue.risk_score_seeds.first.issue_id).to eq(duplicate_issue.id)
      expect(duplicate_issue.risk_score_seeds.first.score).to eq('High')
      expect(duplicate_issue.risk_score_seeds.first.provider).to eq('Compliance Legacy')
      expect(duplicate_issue.risk_score_seeds.first.extra_info).to eq('El TAX ID ingresado por el usuario ya se encuentra registrado')
      
      expect(duplicate_issue.affinity_seeds.count).to eq(2)
      expect(duplicate_issue.affinity_seeds.first.issue_id).to eq(duplicate_issue.id)
      expect(duplicate_issue.affinity_seeds.first.affinity_kind_id).to eq(AffinityKind.compliance_liaison.id)
      expect(duplicate_issue.affinity_seeds.first.related_person_id).to eq(invoicing_person.id)
  
      expect(duplicate_issue.affinity_seeds.second.issue_id).to eq(duplicate_issue.id)
      expect(duplicate_issue.affinity_seeds.second.affinity_kind_id).to eq(AffinityKind.compliance_liaison.id)
      expect(duplicate_issue.affinity_seeds.second.related_person_id).to eq(identification_person.id)
    end
  
    it 'Finds duplicates Chile national_id on identifications and invoicing and then creates alerts' do
      invoicing_person = create(:empty_person)
      invoicing_issue = create(:basic_issue, person: invoicing_person)
      invoicing_seed = ChileInvoicingDetailSeed.create(
        tax_id: '123456789K',
        giro: 'Venta de Electrodomesticos  ',
        ciudad: 'Santiago',
        comuna: 'Las condes',
        vat_status_code: :inscripto,
        issue: invoicing_issue,
      )
      invoicing_issue.complete!
      invoicing_issue.reload
  
      identification_person = create(:empty_person)
      identification_issue = create(:basic_issue, person: identification_person)
      identification_seed = IdentificationSeed.create(
        identification_kind_id: IdentificationKind.national_id.id,
        number: '12.3456.789-K',
        issuer: 'CL',
        issue_id: identification_issue.id
      )
      identification_issue.reload
      identification_issue.complete!
  
      duplicate_person = create(:empty_person)
      duplicate_issue = create(:basic_issue, person: duplicate_person)
      duplicate_seed = IdentificationSeed.create(
        identification_kind_id: IdentificationKind.national_id.id,
        number: '12-3456-789K',
        issuer: 'CL',
        issue_id: duplicate_issue.id
      )
      duplicate_issue.reload
      duplicate_issue.complete!
  
      duplicate_issue.reload
      expect(duplicate_issue.risk_score_seeds.count).to eq(1)
      expect(duplicate_issue.risk_score_seeds.first.issue_id).to eq(duplicate_issue.id)
      expect(duplicate_issue.risk_score_seeds.first.score).to eq('High')
      expect(duplicate_issue.risk_score_seeds.first.provider).to eq('Compliance Legacy')
      expect(duplicate_issue.risk_score_seeds.first.extra_info).to eq('El TAX ID ingresado por el usuario ya se encuentra registrado')
      
      expect(duplicate_issue.affinity_seeds.count).to eq(2)
      expect(duplicate_issue.affinity_seeds.first.issue_id).to eq(duplicate_issue.id)
      expect(duplicate_issue.affinity_seeds.first.affinity_kind_id).to eq(AffinityKind.compliance_liaison.id)
      expect(duplicate_issue.affinity_seeds.first.related_person_id).to eq(invoicing_person.id)
  
      expect(duplicate_issue.affinity_seeds.second.issue_id).to eq(duplicate_issue.id)
      expect(duplicate_issue.affinity_seeds.second.affinity_kind_id).to eq(AffinityKind.compliance_liaison.id)
      expect(duplicate_issue.affinity_seeds.second.related_person_id).to eq(identification_person.id)
    end
  end
end
