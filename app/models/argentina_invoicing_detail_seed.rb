class ArgentinaInvoicingDetailSeed < ApplicationRecord
  include Garden::Seed
  validates :tax_id_type, tax_id_type: true
  validates :receipt_type, receipt_type: true
  validates :country, country: true
  validates :address, presence: true 
  validates :name, presence: true
end
