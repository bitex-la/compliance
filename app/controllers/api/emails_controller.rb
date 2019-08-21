class Api::EmailsController < Api::ReadOnlyEntityController
  def resource_class
    Email
  end
end
