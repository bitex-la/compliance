class Api::ChileInvoicingDetailsController < Api::ReadOnlyEntityController
  def resource_class
    ChileInvoicingDetail
  end

  def related_person
    resource.issue.person_id
  end
end
