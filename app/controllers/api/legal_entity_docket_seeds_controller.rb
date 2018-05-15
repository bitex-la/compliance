class Api::LegalEntityDocketSeedsController < Api::SingleResourceIssueJsonApiSyncController
  def get_resource(scope)
    scope.legal_entity_docket_seed
  end
end
