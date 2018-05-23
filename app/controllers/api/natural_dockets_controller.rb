class Api::NaturalDocketsController < Api::PersonJsonApiController
  def index
    scoped_collection{|s| s.natural_dockets }
  end

  def get_resource(scope)
    scope.natural_dockets.find(params[:id])
  end
end
