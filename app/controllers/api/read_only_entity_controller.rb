class Api::ReadOnlyEntityController < Api::ApiController
  def index
    scope = collection.ransack(params[:filter]).result

    page, per_page = Util::PageCalculator.call(params, 0, 10)
    paginated = scope.page(page).per(per_page)

    jsonapi_response paginated, options_for_response.merge!(
      meta: {
        total_pages: (scope.count.to_f / per_page).ceil,
        total_items: scope.count
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
    collection.find(params[:id])
  end

  def collection
    resource_class.order(updated_at: :desc, id: :desc)
  end
end
