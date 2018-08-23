class RiskScore < ApplicationRecord
  include Garden::Fruit
  
  def self.name_body(i)
    "#{i.provider} #{i.score}"
  end
end
