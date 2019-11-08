class Api::NotesController < Api::ReadOnlyEntityController
  def resource_class
    Note
  end

  def related_person
    resource.issue.person_id
  end
end
