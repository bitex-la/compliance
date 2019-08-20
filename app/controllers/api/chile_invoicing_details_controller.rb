class Api::ChileInvoicingDetailsController < Api::ReadOnlyEntityController
  def resource_class
    ChileInvoicingDetail
  end
end
