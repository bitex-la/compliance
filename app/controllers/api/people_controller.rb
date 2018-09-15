class Api::PeopleController < Api::ApiController
  def index
    scope = Person.ransack(params[:filter]).result
    page, per_page = Util::PageCalculator.call(params, 0, 10)
    people = scope.page(page).per(per_page)
    jsonapi_response( people,
      meta: { total_pages: (scope.count.to_f / per_page).ceil }
    )
  end

  def show
    jsonapi_response Person.find(params[:id]), {}
  end

  def create
    jsonapi_response Person.create, {}, 201
  end

  def update
    mapper = JsonapiMapper.doc_unsafe!(
      params.permit!.to_h, [:people], people: %I[enabled risk])

    return jsonapi_422(nil) unless mapper.data

    if mapper.save_all
      jsonapi_response mapper.data, {}, 200
    else
      json_response mapper.all_errors, 422
    end
  end

  def simple_jsonapi_response(type, attributes)
    { data: { 
        id: attributes['id'],
        type: type,
        attributes: attributes.except('id') } 
    }
  end
end
