require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe ChileInvoicingDetail do
  it_behaves_like 'jsonapi show and index',
    :chile_invoicing_details,
    :full_chile_invoicing_detail_with_person,
    :alt_full_chile_invoicing_detail_with_person,
    {vat_status_code_eq: 'consumidor_final'},
    'comuna,vat_status_code,person',
    'person,seed'

  it_behaves_like 'jsonapi show and index',
    :chile_invoicing_detail_seeds,
    :full_chile_invoicing_detail_seed_with_issue,
    :alt_full_chile_invoicing_detail_seed_with_issue,
    {vat_status_code_eq: 'consumidor_final'},
    'comuna,vat_status_code,issue',
    'issue,attachments'

  it_behaves_like('seed', :chile_invoicing_details,
    :full_chile_invoicing_detail,
    :alt_full_chile_invoicing_detail)

  it_behaves_like('has_many fruit', :chile_invoicing_details,
    :full_chile_invoicing_detail)
end
