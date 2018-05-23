class Api::IdentificationsController < Api::PersonJsonApiController
  def index
    scoped_collection{|s| s.identifications }
  end

  def get_resource(scope)
    scope.identifications.find(params[:id])
  end
end
