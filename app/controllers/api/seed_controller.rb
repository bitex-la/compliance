class Api::SeedController < Api::ApiController
  def index
    page, per_page = Util::PageCalculator.call(params, 0, 10)
    collection = resource_class.order(updated_at: :desc).page(page).per(per_page)

    jsonapi_response collection, options_for_response.merge!(
      meta: { total_pages: (resource.count.to_f / per_page).ceil })
  end

  def show
    jsonapi_response resource, options_for_response
  end

  def create
    map_and_save(201)
  end

  def update
    # Force json-api ID to match the route id.
    begin
      params[:data][:id] = resource.id
    rescue NoMethodError
      return jsonapi_422(nil)
    end

    map_and_save(200)
  end

  protected

  def resource
    resource_class.find(params[:id])
  end

  def map_and_save(success_code)
    mapper = get_mapper
    return jsonapi_422(nil) unless mapper.data

    if mapper.save_all
      jsonapi_response mapper.data, options_for_response, success_code
    else
      json_response mapper.all_errors, 422
    end
  end

  def options_for_response
    {}
  end
end
