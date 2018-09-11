module IssueApiExpirable
  extend ActiveSupport::Concern

  included do 
    after_save :expire_action_cache
  end

  private 
    def expire_action_cache
      ActionController::Base.new
        .expire_fragment("api/people/#{self.person.id}/issues")
      ActionController::Base.new
        .expire_fragment("api/people/#{self.person.id}/issues/#{self.id}")
    end
end