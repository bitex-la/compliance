class Api::ArgentinaInvoicingDetailsController < Api::ReadOnlyEntityController
  def resource_class
    ArgentinaInvoicingDetail
  end

  def related_person
    resource.issue.person_id
  end
end
