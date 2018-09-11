class Api::ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  include ApiResponse
  before_action :require_token

  caches_action :index, expires_in: 10.minutes, cache_path: :path_for_index
  caches_action :show, expires_in: 10.minutes, cache_path: :path_for_show

 
    def path_for_index
      path = "#{params[:controller]}/#{params[:action]}"
      params.select{|x| x.include? "_id"}.keys.each do |k|
        path = "#{path}/#{k}/#{params[k]}"
      end
      unless params[:page].nil?
        path = "#{path}/page/#{params[:page][:page]}" unless params[:page][:page].nil?
        path = "#{path}/per_page/#{params[:page][:per_page]}" unless params[:page][:per_page].nil?
      end 
      path
    end

    def path_for_show
      path = "#{params[:controller]}/#{params[:action]}"
      path = "#{path}/id/#{params[:id]}"
      params.select{|x| x.include? "_id"}.keys.each do |k|
        path = "#{path}/#{k}/#{params[k]}"
      end
    end
    
  private
    def require_token
      authenticate_token || jsonapi_403
    end

    def authenticate_token
      authenticate_with_http_token do |token, options|
        AdminUser.find_by(api_token: token)
      end
    end
end
