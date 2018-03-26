class ArgentinaInvoicingDetail < ApplicationRecord
  include Garden::Fruit
  validates :tax_id_type, tax_id_type: true
  validates :receipt_type, receipt_type: true
  validates :country, country: true
  validates :address, presence: true
  validates :name, presence: true

  def name
    [id, vat_status_id, tax_id].join(",")
  end
end
