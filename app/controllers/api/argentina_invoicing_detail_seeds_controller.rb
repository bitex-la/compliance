class Api::ArgentinaInvoicingDetailSeedsController < Api::SingleResourceIssueJsonApiSyncController
  def get_resource(scope)
    scope.argentina_invoicing_detail_seed
  end
end
