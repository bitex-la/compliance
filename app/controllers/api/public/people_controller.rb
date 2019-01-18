class Api::Public::PeopleController < Api::Public::ApiController
  before_action :verify_scope

  def show
    jsonapi_public_response Person.find(params[:id])
  end

  private

  def verify_scope
    token = request.env['api_token']
    return if Person.find_by(api_token: token).id.to_s == params[:id]
    jsonapi_404
  end
end