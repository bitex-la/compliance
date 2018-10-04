class Api::EventLogsController < Api::FruitController
  def resource_class
    EventLog
  end
end
