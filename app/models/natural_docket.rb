class NaturalDocket < ApplicationRecord
  include Garden::Fruit
  
  def name
    [id, first_name, last_name, gender].join(',')    
  end
end
