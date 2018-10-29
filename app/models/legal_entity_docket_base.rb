class LegalEntityDocketBase < ApplicationRecord
  strip_attributes
  self.abstract_class = true
  validates :country, country: true

  def name_body
    commercial_name || legal_name
  end
end
