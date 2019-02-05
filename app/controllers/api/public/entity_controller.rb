class Api::Public::EntityController < Api::Public::ApiController
  before_action :verify_scope, only: [:show, :update]

  def show
    jsonapi_public_response resource
  end

  def create
    map_and_save(201)
  end

  def update
    # Force json-api ID to match the route id.
    begin
      params[:data][:id] = resource.id
    rescue NoMethodError
      return jsonapi_422
    end

    map_and_save(200)
  end

  def options_for_response
    {}
  end

  protected

  def resource
    @resource ||= resource_class.find(params[:id])
  end

  def map_and_save(success_code)
    mapper = get_mapper
    return jsonapi_422 unless mapper.data

    if mapper.data.save
      jsonapi_public_response mapper.data, options_for_response, success_code
    else
      json_response mapper.all_errors, 422
    end
  end

  private

  def verify_scope
    request_token = request.env['api_token']
    token = if resource.respond_to?(:issue)
      resource.issue.person.api_token
    end
    return if request_token == token
    jsonapi_404
  end
end
