class Api::PeopleController < Api::ApiController
  def index
    scope = Person.all
    page, per_page = Util::PageCalculator.call(params, 0, 10)
    people = scope.page(page).per(per_page)
    jsonapi_response people,
      meta: { total_pages: (scope.count.to_f / per_page).ceil }
  end

  def show
    begin 
      jsonapi_response Person.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      errors = []
      errors << JsonApi::Error.new({
        links:   {},
        status:  404,
        code:    "person_not_found",
        title:   "person not found",
        detail:  "person_not_found",
        source:  {},
        meta:    {}
      })
      error_response(errors)
    end
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
      jsonapi_response mapper.data
    else
      json_response mapper.all_errors, 422
    end	
  end
end
