class Api::EventLogsController < Api::ApiController
  def index
    page, per_page = Util::PageCalculator.call(params, 0, 50)
    events = if !params[:filter].blank?
      EventLog
        .where(entity_type: params[:filter][:entity_type], verb_id: EventLogKind.send(params[:filter][:verb]).id)
        .order(updated_at: :desc)
        .page(page)
        .per(per_page)
    else 
      EventLog.order(updated_at: :desc).page(page).per(per_page)
    end
    options = {
      meta: { total_pages: (events.count.to_f / per_page).ceil },
    }
    jsonapi_response events, options, 200
  end

  def show
    event = EventLog.find(params[:id])
    jsonapi_response(event, {}, 200)
  end
end
