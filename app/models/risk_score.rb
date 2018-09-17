class RiskScore < RiskScoreBase
  include Garden::Fruit
  
  def self.name_body(i)
    "#{i.provider} #{i.score}"
  end
end
