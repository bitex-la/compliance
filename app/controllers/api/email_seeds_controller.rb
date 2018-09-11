class Api::EmailSeedsController < Api::IssueJsonApiSyncController
  def index
    scoped_collection{|s| s.email_seeds }
  end

  def get_resource(scope)
    scope.email_seeds.find(params[:id])
  end

  private 
  def path_for_index
    "api/people/#{params[:person_id]}/issues/#{params[:issue_id]}/email_seeds"
  end

  def path_for_detail
    "api/people/#{params[:person_id]}/issues/#{params[:issue_id]}/email_seeds/#{params[:id]}"
  end
end
