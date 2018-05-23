class Api::AffinitiesController < Api::PersonJsonApiController
  def index
    scoped_collection{|s| s.affinities }
  end

  def get_resource(scope)
    scope.affinities.find(params[:id])
  end
end
