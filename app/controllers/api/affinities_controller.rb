class Api::AffinitiesController < Api::FruitController
  def resource_class
    Affinity
  end
end
