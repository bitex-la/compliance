require 'rails_helper'

RSpec.describe ChileInvoicingDetail, type: :model do
  it_behaves_like 'fruit_scopeable', :chile_invoicing_details,
    :full_chile_invoicing_detail
end
