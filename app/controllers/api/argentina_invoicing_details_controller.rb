class Api::ArgentinaInvoicingDetailsController < Api::PersonJsonApiController
  def index
    scoped_collection{|s| s.argentina_invoicing_details }
  end

  def get_resource(scope)
    scope.argentina_invoicing_details.find(params[:id])
  end
end
