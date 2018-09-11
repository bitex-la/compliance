class Api::NotesController < Api::FruitController
  def resource_class
    Note
  end
end
