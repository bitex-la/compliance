class ChileInvoicingDetail < ApplicationRecord
  include Garden::Fruit
  include Garden::Kindify

  validates :vat_status, inclusion: { in: VatStatusKind.all.map(&:code) }

  kind_mask_for :vat_status, "VatStatusKind"

  def name
    [id, vat_status, tax_id, giro, ciudad, comuna].join(",")
  end
end
