class Api::ChileInvoicingDetailSeedsController < Api::SingleResourceIssueJsonApiSyncController
  def get_resource(scope)
    scope.chile_invoicing_detail_seed
  end
end
