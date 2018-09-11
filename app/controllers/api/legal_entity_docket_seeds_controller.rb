class Api::LegalEntityDocketSeedsController < Api::SingleResourceIssueJsonApiSyncController
  def get_resource(scope)
    scope.legal_entity_docket_seed
  end

  private 
  def path_for_index
    "api/people/#{params[:person_id]}/issues/#{params[:issue_id]}/legal_entity_docket_seeds"
  end

  def path_for_detail
    "api/people/#{params[:person_id]}/issues/#{params[:issue_id]}/legal_entity_docket_seeds/#{params[:id]}"
  end
end
