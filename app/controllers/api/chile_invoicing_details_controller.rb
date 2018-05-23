class Api::ChileInvoicingDetailsController < Api::PersonJsonApiController
  def index
    scoped_collection{|s| s.chile_invoicing_details }
  end

  def get_resource(scope)
    scope.chile_invoicing_details.find(params[:id])
  end
end
