class Api::PhonesController < Api::PersonJsonApiController
  def index
    scoped_collection{|s| s.phones }
  end

  def get_resource(scope)
    scope.phones.find(params[:id])
  end
end
