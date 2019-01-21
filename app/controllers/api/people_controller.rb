class Api::PeopleController < Api::ApiController
  caches_action :show, expires_in: 2.minutes, cache_path: :path_for_show

  def index
    scope = Person.ransack(params[:filter]).result
    page, per_page = Util::PageCalculator.call(params, 0, 10)
    people = scope.page(page).per(per_page)
    jsonapi_response( people,
      meta: {
        total_pages: (scope.count.to_f / per_page).ceil,
        total_items: scope.count
      }
    )
  end

  def show
    jsonapi_response Person.find(params[:id]), {}
  end

  def create
    person = if params["data"]
      mapper = JsonapiMapper.doc_unsafe!(
        params.permit!.to_h, [:people], people: %I[external_id])

      mapper.data.save
      mapper.data
    else
      Person.create
    end

    jsonapi_response person, {}, 201
  end

  def update
    mapper = JsonapiMapper.doc_unsafe!(
      params.permit!.to_h, [:people], people: %I[enabled risk external_id])

    return jsonapi_422 unless mapper.data

    if mapper.data.save
      jsonapi_response mapper.data, {}, 200
    else
      json_response mapper.all_errors, 422
    end
  end

  protected

  def path_for_show
    "person/show/#{params[:id]}?#{params.permit!.to_query}"
  end
end
