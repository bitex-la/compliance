class Api::FruitController < Api::ApiController
  def index
    debugger
    page, per_page = Util::PageCalculator.call(params, 0, 10)
    collection = resource_class.all
      .order(updated_at: :desc)
      .page(page)
      .per(per_page)

    jsonapi_response collection, options_for_response.merge!(
      meta: { total_pages: (collection.count.to_f / per_page).ceil })
  end

  def show
    jsonapi_response resource
  end

  protected

  def resource
    resource_class.find(params[:id])
  end

  def options_for_response
    {}
  end
end
