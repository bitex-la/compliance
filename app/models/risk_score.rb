class RiskScore < ApplicationRecord
  include Garden::Fruit
  
  def name
    [id, score, provider].join(',')    
  end
end
