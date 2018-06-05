class Api::ObservationsController < Api::IssueJsonApiSyncController
  def index
    scoped_collection{|s| s.observations }
  end

  def get_resource(scope)
    scope.observations.find(params[:id])
  end
end
