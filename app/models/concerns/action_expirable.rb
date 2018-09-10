module ActionExpirable
  extend ActiveSupport::Concern

  included do 
    after_save :expire_action_cache
  end

  private 
    def expire_action_cache
      debugger
      expire_action(
        controller: '/api/people',          
        action: :show,
        person: self.person)
      expire_action(
        controller: '/api/issues',          
        action: :index,
        person: self.person)
      expire_action(
        controller: '/api/issues',          
        action: :show,
        person: self.person,
        issue: self)
    end
end