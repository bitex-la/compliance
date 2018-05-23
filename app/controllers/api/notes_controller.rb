class Api::NotesController < Api::PersonJsonApiController
  def index
    scoped_collection{|s| s.notes }
  end

  def get_resource(scope)
    scope.notes.find(params[:id])
  end
end
