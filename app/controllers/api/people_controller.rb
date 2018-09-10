class Api::PeopleController < Api::ApiController
  def index
    scope = Person.ransack(params[:filter]).result

    page, per_page = Util::PageCalculator.call(params, 0, 10)
    people = scope.page(page).per(per_page)
    jsonapi_response people,
      meta: { total_pages: (scope.count.to_f / per_page).ceil }
  end

  def show
    jsonapi_response Person
      .preload(*Person::eager_person_entities)
      .find(params[:id])
  end

  def create
    jsonapi_response Person.create, {}, 201
  end

  def update
    mapper = JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [:people],
      people: [:enabled, :risk]

    return jsonapi_422(nil) unless mapper.data

    if mapper.save_all
      jsonapi_response mapper.data, {}, 200
    else
      json_response mapper.all_errors, 422
    end
  end
end
