class Api::DomicilesController < Api::ReadOnlyEntityController
  def resource_class
    Domicile
  end

  def related_person
    resource.person_id
  end
end
