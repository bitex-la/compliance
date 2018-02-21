class Api::PeopleController < Api::ApiController
  def index
    page, per_page = Util::PageCalculator.call(params, 0, 10)
    people = Person.all.page(page).per(per_page)

    options = {}
    options[:meta] = { total_pages: (Person.count.to_f / per_page).ceil }
    json_response JsonApi::ModelSerializer.call(people, options), 200
  end

  def show
    begin 
      person = Person.find(params[:id])
      options = {}
      options[:include] = [
        :issues,
        :natural_dockets,
      ]
      json_response JsonApi::ModelSerializer.call(person, options), 200
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
      jsonapi_response mapper.data, {include: [:issues]}, 201
    else
      json_response mapper.all_errors, 422
    end	
  end
end
