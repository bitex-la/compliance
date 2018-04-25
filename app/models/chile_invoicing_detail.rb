class ChileInvoicingDetail < ApplicationRecord
  include Garden::Fruit
  include Garden::Kindify

  kind_mask_for :vat_status, "VatStatusKind"

  def name
    [id, vat_status, tax_id, giro, ciudad, comuna].join(",")
  end
end
