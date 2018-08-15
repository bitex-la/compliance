class ArgentinaInvoicingDetail < ApplicationRecord
  include Garden::Fruit
  include StaticModels::BelongsTo
  
  validates :country, country: true
  validates :address, presence: true
  validates :name, presence: true
  validates :tax_id_kind, inclusion: { in: TaxIdKind.all }
  validates :receipt_kind, inclusion: { in: ReceiptKind.all }
  validates :vat_status, inclusion: { in: VatStatusKind.all }

  belongs_to :tax_id_kind
  belongs_to :receipt_kind
  belongs_to :vat_status, class_name: 'VatStatusKind'
end
