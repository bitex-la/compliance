class Api::EventLogsController < Api::ApiController
  def index
    page, per_page = Util::PageCalculator.call(params, 0, 50)
    scope = EventLog.all.order(updated_at: :desc)
    if !params[:filter].blank?
      scope = scope.where(
        entity_type: params[:filter][:entity_type], 
        verb_id: EventLogKind.send(params[:filter][:verb]).id)
    end
    
    jsonapi_response scope.page(page).per(per_page), {
      meta: { total_pages: (scope.count.to_f / per_page).ceil }
    }
  end

  def show
    event = EventLog.find(params[:id])
    jsonapi_response(event, {}, 200)
  end
end
