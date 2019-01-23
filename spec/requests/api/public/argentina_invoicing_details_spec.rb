require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe ArgentinaInvoicingDetail do
  it_behaves_like('public seed', :argentina_invoicing_details,
    :full_argentina_invoicing_detail,
    :alt_full_argentina_invoicing_detail)
end

