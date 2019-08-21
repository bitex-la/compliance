class Api::NaturalDocketsController < Api::ReadOnlyEntityController
  def resource_class
    NaturalDocket
  end
end
