class RiskScoreBase < ApplicationRecord
  self.abstract_class = true

  validates :score, :provider, length: { maximum: 255 }

  def name_body
    "#{provider} #{score}"
  end

  def extra_info_hash
    JSON.parse(extra_info)
  end
end
