class Api::IssuesController < Api::ApiController
  def index
    scope = Issue
      .includes(*build_eager_load_list)
      .order(updated_at: :desc)
      .ransack(params[:filter])
      .result

    page, per_page = Util::PageCalculator.call(params, 0, 3)
    issues = scope.page(page).per(per_page)

    jsonapi_response issues, {
      include: params[:include] || Issue.included_for,
      meta: {
        total_pages: (scope.count.to_f / per_page).ceil,
        total_items: scope.count
      }
    }
  end

  def show
    issue = Issue.includes(*build_eager_load_list).find(params[:id])
    jsonapi_response issue, {include: params[:include] || Issue.included_for}
  end

  def create
    mapper = JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [ :people ],
      issues: [:reason_code, :defer_until, :person, id: nil ],
      people: []

    return jsonapi_422(nil) unless mapper.data

    if mapper.save_all
      jsonapi_response mapper.data,
        {include: params[:include] || Issue.included_for}, 201
    else
      json_response mapper.all_errors, 422
    end
  end

  Issue.aasm.events.map(&:name).each do |action|
    define_method(action) do
      issue = Issue.find(params[:id])
      begin
        issue.aasm.fire!(action)
        jsonapi_response(issue, {}, 200)
      rescue AASM::InvalidTransition => e
				jsonapi_error(422, "invalid transition")
      end
    end
  end

  private

  def build_eager_load_list
    [
      *Issue::eager_issue_entities,
      [observations: [:observation_reason]],
      [person: Person::eager_person_entities]
    ]
  end
end
