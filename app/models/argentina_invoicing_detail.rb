class ArgentinaInvoicingDetail < ApplicationRecord
  include Garden::Fruit
  include Garden::Kindify
  validates :country, country: true
  validates :address, presence: true
  validates :name, presence: true
  validates :tax_id_kind, inclusion: { in: TaxIdKind.all.map(&:code) }
  validates :receipt_kind, inclusion: { in: ReceiptKind.all.map(&:code) }
  validates :vat_status, inclusion: { in: VatStatusKind.all.map(&:code) }  

  kind_mask_for :tax_id_kind, "TaxIdKind"
  kind_mask_for :receipt_kind, "ReceiptKind"
  kind_mask_for :vat_status, "VatStatusKind"

  def name
    [id, vat_status, tax_id].join(",")
  end
end
