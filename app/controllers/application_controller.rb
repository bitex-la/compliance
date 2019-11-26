class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_current_user
  before_action :verify_request, except: [:index, :create]

  private

  def set_current_user
    if current_admin_user.nil? 
      authenticate_with_http_token do |token, options|
        AdminUser.current_admin_user = AdminUser.find_by(api_token: token)
      end
    else
      AdminUser.current_admin_user = current_admin_user
    end
  end

  def verify_request
    current_user = AdminUser.current_admin_user
    return if current_user.nil?

    limit = current_user.max_people_allowed
    return if limit.nil?

    person_id = related_person.to_s
    return if person_id.empty?

    set = current_user.request_limit_set
    return if set.member? person_id

    counter = current_user.request_limit_counter

    render body: nil, status: 400 if counter.increment > limit
    set << person_id
  end

  def related_person
  end
end
