class Api::LegalEntityDocketsController < Api::PersonJsonApiController
  def index
    scoped_collection{|s| s.legal_entity_dockets }
  end

  def get_resource(scope)
    scope.legal_entity_dockets.find(params[:id])
  end
end
