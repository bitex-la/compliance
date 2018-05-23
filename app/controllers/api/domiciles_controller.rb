class Api::DomicilesController < Api::PersonJsonApiController
  def index
    scoped_collection{|s| s.domiciles }
  end

  def get_resource(scope)
    scope.domiciles.find(params[:id])
  end
end
