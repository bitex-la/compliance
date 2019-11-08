class Api::AllowancesController < Api::ReadOnlyEntityController
  def resource_class
    Allowance
  end

  def related_person
    resource.issue.person_id
  end
end
