class Api::IdentificationsController < Api::FruitController
  def resource_class
    Identification
  end
end
