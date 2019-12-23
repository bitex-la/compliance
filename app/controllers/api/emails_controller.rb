class Api::EmailsController < Api::ReadOnlyEntityController
  def resource_class
    Email
  end

  def related_person
    resource.person_id
  end
end
