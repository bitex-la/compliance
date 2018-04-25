class ChileInvoicingDetailSeed < ApplicationRecord
  include Garden::Seed
  include Garden::Kindify
  
  kind_mask_for :vat_status, "VatStatusKind"
end
