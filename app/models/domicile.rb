class Domicile < ApplicationRecord
  include Garden::Fruit
  validates :country, country: true 
  
  def name
    build_name("#{country} #{street_address}")
  end
end
