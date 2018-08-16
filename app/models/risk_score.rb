class RiskScore < ApplicationRecord
  include Garden::Fruit
  
  def name
    build_name("#{provider} #{score}")
  end
end
