module Loggable
  extend ActiveSupport::Concern

  included do
    after_commit(on: [:create]) { log(:create_entity) }
    after_commit(on: [:update]) { log(:update_entity) }

    def log(verb)
      "Event::#{self.class.name}Logger".constantize.call(
        self, 
        AdminUser.current_admin_user,
        verb
      )
    end  
  end
end
