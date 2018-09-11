class Api::ChileInvoicingDetailSeedsController < Api::SingleResourceIssueJsonApiSyncController
  def get_resource(scope)
    scope.chile_invoicing_detail_seed
  end

  private 
  def path_for_index
    "api/people/#{params[:person_id]}/issues/#{params[:issue_id]}/chile_invoicing_detail_seeds"
  end

  def path_for_detail
    "api/people/#{params[:person_id]}/issues/#{params[:issue_id]}/chile_invoicing_detail_seeds/#{params[:id]}"
  end
end
