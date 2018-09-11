module SeedApiExpirable
  extend ActiveSupport::Concern

  included do 
    after_save :expire_action_cache
  end

  private 
    def expire_action_cache
      #ActionController::Base.new
      #  .expire_fragment("api/people/#{self.person.id}/issues/#{self.issue.id}/#{seed_path}")
      #ActionController::Base.new
      #  .expire_fragment("api/people/#{self.person.id}/issues/#{self.issue.id}/#{seed_path}/#{self.id}")

      show_wilcard = "api/#{seed_path}/show/#{self.id}"
      index_wildcard = "api/#{seed_path}/show/person_id/#{self.issue.person.id}/issue_id/#{self.issue.id}"

      seed_path = Garden::Naming.new(self.class.name).seed_plural
      ActionController::Base.new
        .expire_fragment(/#{show_wilcard}/i)
      ActionController::Base.new
        .expire_fragment(/#{index_wildcard}/i)
    end
end