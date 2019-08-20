class Api::EventLogsController < Api::ReadOnlyEntityController
  def resource_class
    EventLog
  end
end
