class Api::RiskScoresController < Api::PersonJsonApiController
  def index
    scoped_collection{|s| s.risk_scores }
  end

  def get_resource(scope)
    scope.risk_scores.find(params[:id])
  end
end