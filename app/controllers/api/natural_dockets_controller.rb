class Api::NaturalDocketsController < Api::ReadOnlyEntityController
  def resource_class
    NaturalDocket
  end

  def related_person
    resource.person_id
  end
end
