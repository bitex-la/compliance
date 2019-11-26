class Api::LegalEntityDocketsController < Api::ReadOnlyEntityController
  def resource_class
    LegalEntityDocket
  end

  def related_person
    resource.issue.person_id
  end
end
