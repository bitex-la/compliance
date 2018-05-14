class Api::LegalEntityDocketSeedController < Api::IssueJsonApiSyncController
  def index
    show
  end

  def get_resource(scope)
    scope.legal_entity_docket_seed
  end
end
