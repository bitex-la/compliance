class Api::NoteSeedsController < Api::IssueJsonApiSyncController
  def index
    scoped_collection{|s| s.note_seeds }
  end

  def get_resource(scope)
    scope.note_seeds.find(params[:id])
  end
end
