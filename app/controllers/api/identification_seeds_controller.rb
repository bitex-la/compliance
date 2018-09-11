class Api::IdentificationSeedsController < Api::IssueJsonApiSyncController
  def index
    scoped_collection{|s| s.identification_seeds }
  end

  def get_resource(scope)
    scope.identification_seeds.find(params[:id])
  end
end
