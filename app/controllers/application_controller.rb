class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_current_user
  before_action :verify_request, except: :index

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
    return if AdminUser.current_admin_user.nil?

    limit = AdminUser.current_admin_user.max_people_allowed
    return if limit.nil?

    person_id = related_person.to_s
    return if person_id.empty?

    now = Time.now
    now_string = now.strftime('%Y%m%d')
    expire_at = now.end_of_day

    set = Redis::Set.new("request_limit:people:#{AdminUser.current_admin_user.id}:#{now_string}", :expireat => expire_at)
    counter = Redis::Counter.new("request_limit:counter:#{AdminUser.current_admin_user.id}:#{now_string}", :expireat => expire_at)

    if counter.increment <= limit
      if set.member? person_id
        counter.decrement
      else
        set << person_id
      end
    else
      counter.decrement
      render nothing: true, status: 400 unless set.member? person_id
    end
  end

  def related_person
  end
end
