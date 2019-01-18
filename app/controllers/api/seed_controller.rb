class Api::SeedController < Api::FruitController
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

  def destroy 
    resource.destroy
    render body: nil, status: 204
  end

  protected

  def map_and_save(success_code)
    mapper = get_mapper
    return jsonapi_422 unless mapper.data

    if mapper.data.save
      jsonapi_response mapper.data, options_for_response, success_code
    else
      json_response mapper.all_errors, 422
    end
  end
end
