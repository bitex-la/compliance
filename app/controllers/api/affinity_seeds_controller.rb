class Api::AffinitySeedsController < Api::IssueJsonApiSyncController
  def index
    scoped_collection{|s| s.affinity_seeds }
  end

  def get_resource(scope)
    scope.affinity_seeds.find(params[:id])
  end
end
