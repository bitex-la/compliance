require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe 'All seed and fruit kinds' do
  it_behaves_like('seed', :legal_entity_dockets,
    :full_legal_entity_docket, :alt_full_legal_entity_docket)

  it_behaves_like('docket', :legal_entity_dockets, :full_legal_entity_docket)

  it_behaves_like('seed', :argentina_invoicing_details,
    :full_argentina_invoicing_detail,
    :alt_full_argentina_invoicing_detail)

  it_behaves_like('seed', :chile_invoicing_details,
    :full_chile_invoicing_detail, :alt_full_chile_invoicing_detail)

  it_behaves_like('seed', :phones, :full_phone, :alt_full_phone)

  it_behaves_like('seed', :domiciles, :full_domicile, :alt_full_domicile)

  it_behaves_like('seed', :emails, :full_email, :alt_full_email)

  it_behaves_like('seed', :identifications,
    :full_natural_person_identification,
    :alt_full_natural_person_identification)

  it_behaves_like('seed', :allowances,
    :salary_allowance, :alt_salary_allowance)

  it_behaves_like('seed', :risk_scores,
    :full_risk_score, :alt_full_risk_score)

  it_behaves_like('seed', :notes, :full_note, :alt_full_note)

  it_behaves_like('seed', :affinities, :full_affinity, :alt_full_affinity,
    -> {
      {related_person: {
        data: {id: create(:empty_person).id.to_s, type: 'people'}}
      }
    })

  it_behaves_like('has_many fruit', :argentina_invoicing_details,
    :full_argentina_invoicing_detail)

  it_behaves_like('has_many fruit', :chile_invoicing_details,
    :full_chile_invoicing_detail)

  it_behaves_like('has_many fruit', :phones, :full_phone)

  it_behaves_like('has_many fruit', :domiciles, :full_domicile)

  it_behaves_like('has_many fruit', :emails, :full_email)

  it_behaves_like('has_many fruit', :identifications,
    :full_natural_person_identification)

  it_behaves_like('has_many fruit', :allowances, :salary_allowance)

  it_behaves_like('has_many fruit', :risk_scores, :full_risk_score)

  it_behaves_like('has_many fruit', :notes, :full_note)

  it_behaves_like('has_many fruit', :affinities, :full_affinity, -> {
    { related_person: {
        data: {id: create(:empty_person).id.to_s, type: 'people'}
      }
    }
  })
end
