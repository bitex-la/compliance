class Api::AffinitySeedsController < Api::IssueJsonApiSyncController
  def index
    scoped_collection{|s| s.affinity_seeds }
  end

  def get_resource(scope)
    scope.affinity_seeds.find(params[:id])
  end

  private 
  def path_for_index
    "api/people/#{params[:person_id]}/issues/#{params[:issue_id]}/affinity_seeds"
  end

  def path_for_detail
    "api/people/#{params[:person_id]}/issues/#{params[:issue_id]}/affinity_seeds/#{params[:id]}"
  end
end
