class RiskScoreBase < ApplicationRecord
  self.abstract_class = true
  
  def name_body
    "#{provider} #{score}"
  end

  def extra_info_hash
    JSON.parse(extra_info)
  end
end
