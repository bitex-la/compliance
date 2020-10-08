class LegalEntityDocketBase < ApplicationRecord
  strip_attributes
  self.abstract_class = true
  validates :country, country: true, length: { maximum: 255 }
  validates :industry, :commercial_name, :legal_name, length: { maximum: 255 }

  def name_body
    commercial_name || legal_name
  end
end
