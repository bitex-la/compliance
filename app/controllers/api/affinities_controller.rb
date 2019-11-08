class Api::AffinitiesController < Api::ReadOnlyEntityController
  def resource_class
    Affinity
  end

  def related_person
    resource.issue.person_id
  end
end
