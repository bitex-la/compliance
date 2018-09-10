class Api::ObservationReasonsController < Api::ApiController
  caches_action :index, expires_in: 5.minutes

  def index
    page, per_page = Util::PageCalculator.call(params, 0, 100)
    observation_reasons = ObservationReason.all.page(page).per(per_page)
    options = { meta: { total_pages: (observation_reasons.count.to_f / per_page).ceil } }
    jsonapi_response observation_reasons, options, 200
  end
end
