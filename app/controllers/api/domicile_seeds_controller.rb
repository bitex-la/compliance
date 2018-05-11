class Api::DomicileSeedController < Api::IssueJsonApiSyncController
  def index
    scoped_collection{|s| s.domicile_seeds }
  end

  def get_resource(scope)
    scope.domicile_seeds.find(params[:id])
  end
end
