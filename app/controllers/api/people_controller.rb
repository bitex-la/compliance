class Api::PeopleController < Api::ApiController
  before_action :validate_processable, only: [:create, :update]
  protect_from_forgery :except => [:create]

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
    person, errors = People::PeopleCreator.call(params.permit!.to_h)
    if errors.empty?
      json_response JsonApi::ModelSerializer.call(person), 201
    else
      error_response(errors)
    end	
  end
end
