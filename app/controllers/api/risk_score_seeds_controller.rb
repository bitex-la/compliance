class Api::RiskScoreSeedsController < Api::IssueJsonApiSyncController
  def index
    scoped_collection{|s| s.risk_score_seeds }
  end

  def get_resource(scope)
    scope.risk_score_seeds.find(params[:id])
  end
end