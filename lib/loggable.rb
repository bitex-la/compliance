module Loggable
  extend ActiveSupport::Concern

  included do
    has_many :event_logs, as: :entity

    after_commit(on: [:create]) { log(:create_entity) }
    after_commit(on: [:update]) { log(:update_entity) }

    def log(verb)
      EventLog.log_entity!(self, AdminUser.current_admin_user,
        EventLogKind.send(verb))
    end  
  end
end
