class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_current_user
  before_action :verify_request, except: [:index, :create, :new, :batch_action]
  after_action :clear_current_user

  private

  def set_current_user
    if current_admin_user.nil?
      authenticate_with_http_token do |token, _options|
        AdminUser.current_admin_user = AdminUser.find_by(api_token: token)
      end
    else
      AdminUser.current_admin_user = current_admin_user
    end
  end

  def clear_current_user
    AdminUser.current_admin_user = nil
  end

  def verify_request
    current_admin_user = AdminUser.current_admin_user
    return if current_admin_user.nil?

    person_id = related_person.to_s
    return if person_id.empty?

    set = current_admin_user.request_limit_set
    limit = current_admin_user.max_people_allowed

    if limit.nil?
      # If the limit is not configured or was changed, don't delete
      # rejected people to allow queries from admin page until expiration.
      # Only increment the allowed people score.
      set.increment person_id
    else
      counter = current_admin_user.request_limit_counter
      rejected_set = current_admin_user.request_limit_rejected_set

      # If there are configured limit and the person is already
      # in the allowed set, increments the score.
      if set.member? person_id
        set.increment person_id
      else
        # If the person is not in the set, increment size atomically
        # and validate limit.
        if counter.increment <= limit
          # If the new counter value is less or equal to limit
          # increments the allowed people score.
          # If the person is already in the allowed set,
          # decrements the counter to make place to future people.
          # Using increment method avoid a race condition between two or more
          # concurrent requests.
          unless set.increment(person_id) == 1
            counter.decrement
          end
          # Deletes person if is already on rejected set
          rejected_set.delete person_id
        else
          # If the limit reach the maximum, decrements the counter to
          # allow dynamic changes to the limit, increments the rejected
          # people set score and returns 404 error.
          counter.decrement
          rejected_set.increment person_id
          render body: nil, status: 400
        end
      end
    end
  end

  def related_person
  end
end
