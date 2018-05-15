class Api::NaturalDocketSeedsController < Api::SingleResourceIssueJsonApiSyncController
  def get_resource(scope)
    scope.natural_docket_seed
  end
end
