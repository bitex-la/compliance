class ChileInvoicingDetailBase < ApplicationRecord
  strip_attributes
  self.abstract_class = true
  validates :vat_status, inclusion: { in: VatStatusKind.all }

  validates :vat_status_id, :tax_id, :giro, :ciudad, :comuna, :tax_id_normalized,
    length: { maximum: 255 }

  ransackable_static_belongs_to :vat_status, class_name: "VatStatusKind"

  def name_body
    "RUT #{tax_id}"
  end

  def tax
    "#{tax_id}"
  end

  def normalize_tax_id
    Util::NormalizeIdentifications.normalize_tax_id(self.tax_id, Util::NormalizeIdentifications.chile_tax_id_regx)
  end
end
