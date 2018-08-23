class Domicile < ApplicationRecord
  include Garden::Fruit
  validates :country, country: true 
  
  def self.name_body(i)
    "#{i.city}, #{[i.street_address, i.street_number].join(' ')}"
  end
end
