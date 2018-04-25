class ArgentinaInvoicingDetail < ApplicationRecord
  include Garden::Fruit
  include Garden::Kindify
  #validates :tax_id_type, tax_id_type: true
  #validates :receipt_type, receipt_type: true
  validates :country, country: true
  validates :address, presence: true
  validates :name, presence: true

  kind_mask_for :tax_id_kind, "TaxIdKind"
  kind_mask_for :receipt_kind, "ReceiptKind"
  kind_mask_for :vat_status, "VatStatusKind"

  def name
    [id, vat_status, tax_id].join(",")
  end
end
