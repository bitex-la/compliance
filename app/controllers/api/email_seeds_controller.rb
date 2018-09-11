class Api::EmailSeedsController < Api::IssueJsonApiSyncController
  def index
    scoped_collection{|s| s.email_seeds }
  end

  def get_resource(scope)
    scope.email_seeds.find(params[:id])
  end
end
