class ChileInvoicingDetail < ApplicationRecord
  include Garden::Fruit

  def name
    [id, tax_id, giro, ciudad, comuna].join(",")
  end
end
