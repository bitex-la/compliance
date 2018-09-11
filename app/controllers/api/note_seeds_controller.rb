class Api::NoteSeedsController < Api::IssueJsonApiSyncController
  def index
    scoped_collection{|s| s.note_seeds }
  end

  def get_resource(scope)
    scope.note_seeds.find(params[:id])
  end

  private 
  def path_for_index
    "api/people/#{params[:person_id]}/issues/#{params[:issue_id]}/note_seeds"
  end

  def path_for_detail
    "api/people/#{params[:person_id]}/issues/#{params[:issue_id]}/note_seeds/#{params[:id]}"
  end
end
