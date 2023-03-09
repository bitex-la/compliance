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

  def tax_id_regx
    '^0-9k-kK-K'
  end
end
