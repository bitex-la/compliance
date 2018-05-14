class Api::ChileInvoicingDetailSeedController < Api::IssueJsonApiSyncController
  def index
    show
  end

  def get_resource(scope)
    scope.chile_invoicing_detail_seed
  end
end
