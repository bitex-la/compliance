module SeedApiExpirable
  extend ActiveSupport::Concern

  included do 
    after_save :expire_action_cache
  end

  private 
    def expire_action_cache
      seed_path = Garden::Naming.new(self.class.name).seed_plural
      ActionController::Base.new
        .expire_fragment("api/people/#{self.person.id}/issues/#{self.issue.id}/#{seed_path}")
      ActionController::Base.new
        .expire_fragment("api/people/#{self.person.id}/issues/#{self.issue.id}/#{seed_path}/#{self.id}")
    end
end