class AdminAccessAuthorization < ActiveAdmin::AuthorizationAdapter
  def authorized?(action, subject = nil)
    if user.is_restricted
      klass = subject.class == Class ? subject : subject.class
      
      case action
      when :read, :create, :update
        [Issue, Person, Observation].include?(klass)
      else
        false
      end
    else
      true
    end
  end
end