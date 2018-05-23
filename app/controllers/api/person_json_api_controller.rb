class Api::PersonJsonApiController < Api::ApiController
  def show
    jsonapi_response get_resource(scope)
  end

  def get_resource(scope)
  end

  protected
  def person
    @person ||= Person.find(params[:person_id])
  end

  def scope
    person
  end

  def scoped_collection(&block)
    page, per_page = Util::PageCalculator.call(params, 0, 10)
    resource = block.call(scope)
      .order(updated_at: :desc).page(page).per(per_page)

    jsonapi_response resource, {
      meta: { total_pages: (resource.count.to_f / per_page).ceil }
    }
  end
end
