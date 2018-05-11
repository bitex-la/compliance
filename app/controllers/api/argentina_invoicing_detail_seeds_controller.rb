class Api::ArgentinaInvoicingDetailSeedsController < Api::IssueJsonApiSyncController
  def index
    show
  end

  def get_resource(scope)
    scope.argentina_invoicing_detail_seed
  end
end
