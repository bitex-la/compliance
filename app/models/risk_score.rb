class RiskScore < ApplicationRecord
  include Garden::Fruit
  
  def name
    [self.class.name, id, score, provider].join(',')    
  end
end
