class Domicile < ApplicationRecord
  include Garden::Fruit
  
  def name
    [id, country, city, street_address, street_number].join(',')    
  end 
end
