class ArgentinaInvoicingDetail < ApplicationRecord
  include Garden::Fruit

  def name
    [id, vat_status_id, tax_id].join
  end
end
