class ChileInvoicingDetail < ApplicationRecord
  include Garden::Fruit
  include StaticModels::BelongsTo

  validates :vat_status, inclusion: { in: VatStatusKind.all }

  belongs_to :vat_status, class_name: 'VatStatusKind'

  def name
    [self.class.name, id, vat_status, tax_id, giro, ciudad, comuna].join(",")
  end

  def name
    build_name("#{tax_id} #{vat_status}")
  end
end
