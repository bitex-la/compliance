class Api::NotesController < Api::ReadOnlyEntityController
  def resource_class
    Note
  end
end
