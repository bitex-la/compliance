class Api::RiskScoresController < Api::ReadOnlyEntityController
  def resource_class
    RiskScore
  end
end
