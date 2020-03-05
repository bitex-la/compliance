class Api::ReadOnlyEntityController < Api::ApiController
  def index
    collection = resource_class
      .order(updated_at: :desc, id: :desc)
      .ransack(params[:filter])
      .result

    page, per_page = Util::PageCalculator.call(params, 0, 10)
    paginated = collection.page(page).per(per_page)

    jsonapi_response paginated, options_for_response.merge!(
      meta: {
        total_pages: (collection.count.to_f / per_page).ceil,
        total_items: collection.count
      })
  end

  def show
    jsonapi_response resource
  end

  def options_for_response
    {}
  end

  protected

  def resource
    resource_class.find(params[:id])
  end
end
