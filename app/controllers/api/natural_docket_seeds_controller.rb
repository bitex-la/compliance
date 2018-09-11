class Api::NaturalDocketSeedsController < Api::SingleResourceIssueJsonApiSyncController
  def get_resource(scope)
    scope.natural_docket_seed
  end

  private 
  def path_for_index
    "api/people/#{params[:person_id]}/issues/#{params[:issue_id]}/natural_docket_seeds"
  end

  def path_for_detail
    "api/people/#{params[:person_id]}/issues/#{params[:issue_id]}/natural_docket_seeds/#{params[:id]}"
  end
end
