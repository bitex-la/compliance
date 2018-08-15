class ChileInvoicingDetailSeed < ApplicationRecord
  include Garden::Seed
  include StaticModels::BelongsTo

  validates :vat_status, inclusion: { in: VatStatusKind.all }
  
  belongs_to :vat_status, class_name: "VatStatusKind"
end
