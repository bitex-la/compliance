class Api::PeopleController < Api::ApiController
  caches_action :show, expires_in: 10.minutes
  caches_action :index, expires_in: 1.minute

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
    expire_action :action => :index
    expire_action :action => :show
    jsonapi_response Person.create, {}, 201
  end
end
