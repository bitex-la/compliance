class Api::AllowancesController < Api::PersonJsonApiController
  def index
    scoped_collection{|s| s.allowances }
  end

  def get_resource(scope)
    scope.allowances.find(params[:id])
  end
end
