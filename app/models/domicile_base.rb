class DomicileBase < ApplicationRecord
  strip_attributes
  self.abstract_class = true

  validates :country, country: true, length: { maximum: 255 }

  validates :state, :city, :street_address, :street_number,
    :postal_code, :floor, :apartment, length: { maximum: 255 }

  def name_body
    "#{city}, #{[street_address, street_number].join(' ')}"
  end
end
