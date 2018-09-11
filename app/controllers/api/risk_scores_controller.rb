class Api::RiskScoresController < Api::FruitController
  def resource_class
    RiskScore
  end
end
