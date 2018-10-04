class ArgentinaInvoicingDetailBase < ApplicationRecord
  self.abstract_class = true

  validates :country, country: true
  validates :full_name, presence: true
  validates :tax_id_kind, inclusion: { in: TaxIdKind.all }
  validates :receipt_kind, inclusion: { in: ReceiptKind.all }
  validates :vat_status, inclusion: { in: VatStatusKind.all }
  
  ransackable_static_belongs_to :tax_id_kind
  ransackable_static_belongs_to :receipt_kind
  ransackable_static_belongs_to :vat_status, class_name: "VatStatusKind"

  def name_body
    "#{tax_id_kind} #{tax_id}"
  end
end
