require 'rails_helper'

RSpec.describe ChileInvoicingDetail, type: :model do
  it_behaves_like 'person_scopable_fruit', :full_chile_invoicing_detail
end
