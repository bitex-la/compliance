class Api::IdentificationsController < Api::ReadOnlyEntityController
  def resource_class
    Identification
  end
end
