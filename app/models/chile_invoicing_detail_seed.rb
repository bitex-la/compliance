class ChileInvoicingDetailSeed < ApplicationRecord
  include Garden::Seed
  include Garden::Kindify

  validates :vat_status, inclusion: { in: VatStatusKind.all.map(&:code) }
  
  kind_mask_for :vat_status, "VatStatusKind"
end
