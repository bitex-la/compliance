class Api::AffinitiesController < Api::ReadOnlyEntityController
  def resource_class
    Affinity
  end
end
