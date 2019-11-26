class Api::IdentificationsController < Api::ReadOnlyEntityController
  def resource_class
    Identification
  end

  def related_person
    resource.issue.person_id
  end
end
