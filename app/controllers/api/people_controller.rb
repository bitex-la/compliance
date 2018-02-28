class Api::PeopleController < Api::ApiController
  def index
    scope = Person.all
    page, per_page = Util::PageCalculator.call(params, 0, 10)
    people = scope.page(page).per(per_page)
    jsonapi_response people,
      meta: { total_pages: (scope.count.to_f / per_page).ceil }
  end

  def show
    jsonapi_response Person.find(params[:id])
  end

  def create
    document = {
      data: {
        type: 'people',
        id: '@1',
        relationships: {
          issues: { data: [{ type: 'issues', id: '@1' }] }
        }
      },
      included: [{ type: 'issues', id: '@1' }]
    }

    mapper = JsonapiMapper.doc_unsafe! document,
      [:people, :issues], people: [:issues], issues: []

    if mapper.save_all
      jsonapi_response mapper.data, {}, 201
    else
      json_response mapper.all_errors, 422
    end	
  end
end
