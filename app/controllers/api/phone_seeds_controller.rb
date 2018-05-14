class Api::PhoneSeedsController < Api::IssueJsonApiSyncController
  def index
    scoped_collection{|s| s.phone_seeds }
  end

  def get_resource(scope)
    scope.phone_seeds.find(params[:id])
  end
end
