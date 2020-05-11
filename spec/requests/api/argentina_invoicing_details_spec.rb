require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe ArgentinaInvoicingDetail do
  it_behaves_like 'jsonapi show and index',
    :argentina_invoicing_details,
    :full_argentina_invoicing_detail_with_person,
    :alt_full_argentina_invoicing_detail_with_person,
    {vat_status_code_eq: 'inscripto'},
    'country,vat_status_code,person',
    'person,seed'

  it_behaves_like 'jsonapi show and index',
    :argentina_invoicing_detail_seeds,
    :full_argentina_invoicing_detail_seed_with_issue,
    :alt_full_argentina_invoicing_detail_seed_with_issue,
    {vat_status_code_eq: 'inscripto'},
    'country,vat_status_code,issue',
    'issue,attachments'

  it_behaves_like 'max people allowed request limit',
    :argentina_invoicing_details,
    :full_argentina_invoicing_detail_with_person

  it_behaves_like 'max people allowed request limit',
    :argentina_invoicing_detail_seeds,
    :full_argentina_invoicing_detail_seed_with_person

  it_behaves_like('seed', :argentina_invoicing_details,
    :full_argentina_invoicing_detail,
    :alt_full_argentina_invoicing_detail)

  it_behaves_like('has_many fruit', :argentina_invoicing_details,
    :full_argentina_invoicing_detail)
end
