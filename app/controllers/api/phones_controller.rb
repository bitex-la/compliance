class Api::PhonesController < Api::ReadOnlyEntityController
  def resource_class
    Phone
  end
end
