class ArgentinaInvoicingDetailBase < ApplicationRecord
  strip_attributes
  self.abstract_class = true

  validates :country, country: true
  validates :full_name, presence: true
  validates :tax_id_kind, inclusion: { in: TaxIdKind.all }
  validates :receipt_kind, inclusion: { in: ReceiptKind.all }
  validates :vat_status, inclusion: { in: VatStatusKind.all }

  validates :vat_status_id, :tax_id, :full_name, :address, :country, :tax_id_normalized,
    length: { maximum: 255 }

  ransackable_static_belongs_to :tax_id_kind
  ransackable_static_belongs_to :receipt_kind
  ransackable_static_belongs_to :vat_status, class_name: "VatStatusKind"

  def name_body
    "#{tax_id_kind} #{tax_id}"
  end

  def tax
    "#{tax_id}"
  end

  def normalize_tax_id
    Util::NormalizeIdentifications.normalize_tax_id(self.tax_id,Util::NormalizeIdentifications.argentina_tax_id_regx)
  end
end
