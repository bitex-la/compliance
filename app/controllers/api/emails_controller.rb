class Api::EmailsController < Api::PersonJsonApiController
  def index
    scoped_collection{|s| s.emails }
  end

  def get_resource(scope)
    scope.emails.find(params[:id])
  end
end
