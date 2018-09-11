class Api::ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  include ApiResponse
  before_action :require_token

  caches_action :index, expires_in: 10.minutes, cache_path: :path_for_index
  caches_action :show, expires_in: 10.minutes, cache_path: :path_for_show

  private
    def path_for_index
      debugger
      "api/people/#{params[:person_id]}/issues"
    end

    def path_for_show
      "api/people/#{params[:person_id]}/issues/#{params[:id]}"
    end
    
    def require_token
      authenticate_token || jsonapi_403
    end

    def authenticate_token
      authenticate_with_http_token do |token, options|
        AdminUser.find_by(api_token: token)
      end
    end
end
