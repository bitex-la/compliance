class Api::PeopleController < Api::ApiController
  def index
    scope = Person.all

    if params[:filter]
      begin
        scope = scope.ransack(JSON.parse(URI.decode(params[:filter]))).result
      rescue JSON::ParserError
        return render plain: "Filter is malformed JSON", status: 400 
      end
    end

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
end
