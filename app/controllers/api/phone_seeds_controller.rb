class Api::PhoneSeedsController < Api::IssueJsonApiSyncController
  def index
    scoped_collection{|s| s.phone_seeds }
  end

  def get_resource(scope)
    scope.phone_seeds.find(params[:id])
  end

  private 
  def path_for_index
    "api/people/#{params[:person_id]}/issues/#{params[:issue_id]}/phone_seeds"
  end

  def path_for_detail
    "api/people/#{params[:person_id]}/issues/#{params[:issue_id]}/phone_seeds/#{params[:id]}"
  end
end
