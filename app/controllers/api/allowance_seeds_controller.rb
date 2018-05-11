class Api::AllowanceSeedsController < Api::IssueJsonApiSyncController
  def index
    scoped_collection{|s| s.allowance_seeds }
  end

  def get_resource(scope)
    scope.allowance_seeds.find(params[:id])
  end
end
