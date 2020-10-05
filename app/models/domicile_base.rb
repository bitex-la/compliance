class DomicileBase < ApplicationRecord
  strip_attributes
  self.abstract_class = true
  validates :country, country: true

  def name_body
    "#{city}, #{[street_address, street_number].join(' ')}"
  end
end
