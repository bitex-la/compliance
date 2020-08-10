class Api::PhonesController < Api::ReadOnlyEntityController
  def resource_class
    Phone
  end

  def related_person
    resource.person_id
  end
end
