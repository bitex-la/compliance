class ChileInvoicingDetailBase < ApplicationRecord
  self.abstract_class = true
  validates :vat_status, inclusion: { in: VatStatusKind.all }
  ransackable_static_belongs_to :vat_status, class_name: "VatStatusKind"
end
