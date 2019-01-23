require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe ChileInvoicingDetail do
  it_behaves_like('public seed', :chile_invoicing_details,
    :full_chile_invoicing_detail,
    :alt_full_chile_invoicing_detail)
end
