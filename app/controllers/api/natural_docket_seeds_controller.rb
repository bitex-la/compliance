class Api::NaturalDocketSeedsController < Api::IssueJsonApiSyncController
  def index
    show
  end

  def get_resource(scope)
    scope.natural_docket_seed
  end
end
