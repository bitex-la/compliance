class Api::EmailsController < Api::FruitController
  def resource_class
    Email
  end
end
