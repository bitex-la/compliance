class RiskScoreBase < ApplicationRecord
  self.abstract_class = true
  
  def name_body
    "#{provider} #{score}"
  end
end
