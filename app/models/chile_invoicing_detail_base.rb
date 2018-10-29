class ChileInvoicingDetailBase < ApplicationRecord
  strip_attributes
  self.abstract_class = true
  validates :vat_status, inclusion: { in: VatStatusKind.all }
  ransackable_static_belongs_to :vat_status, class_name: "VatStatusKind"

  def name_body
    "RUT #{tax_id}"
  end
end
