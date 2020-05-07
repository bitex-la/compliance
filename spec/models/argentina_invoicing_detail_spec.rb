require 'rails_helper'

RSpec.describe ArgentinaInvoicingDetail, type: :model do
  it_behaves_like 'fruit_scopeable', :argentina_invoicing_details,
    :full_argentina_invoicing_detail
end
