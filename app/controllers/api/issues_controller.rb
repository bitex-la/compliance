class Api::IssuesController < Api::ApiController
  def index
    scope = Issue.current
      .includes(*build_eager_load_list)
      .order(updated_at: :desc, id: :desc)
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
      [ :people , :tags],
      issues: [:reason_code, :defer_until, :person, :tags, id: nil ],
      people: [],
      tags: []

    return jsonapi_422 unless mapper.data

    if mapper.save_all
      jsonapi_response mapper.data,
        {include: params[:include] || Issue.included_for}, 201
    else
      json_response mapper.all_errors, 422
    end
  end

  def update
    mapper = JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [],
      issues: [ :defer_until, id: params[:id] ]
      
    return jsonapi_422 unless mapper.data

    if mapper.save_all
      jsonapi_response mapper.data,
        {include: params[:include] || Issue.included_for}, 200
    else
      json_response mapper.all_errors, 422
    end
  end

  Issue.aasm.events.map(&:name).each do |action|
    define_method(action) do
      issue = resource
      begin
        issue.aasm.fire!(action)
        jsonapi_response(issue, {}, 200)
      rescue AASM::InvalidTransition => e
        jsonapi_error(422, "invalid transition")
      end
    end
  end

  %i{
    lock
    unlock  
  }.each do |action|
    define_method(action) do
      issue = resource
      return jsonapi_error(422, "invalid transition") unless issue.send(action.to_s + '_issue!')
      jsonapi_response(issue, {}, 200)
    end
  end

  def renew_lock
    issue = resource
    return jsonapi_error(422, "invalid transition") unless issue.renew_lock!
    jsonapi_response(issue, {}, 200)
  end

  def lock_for_ever
    issue = resource
    return jsonapi_error(422, "invalid transition") unless issue.lock_issue!(false)
    jsonapi_response(issue, {}, 200)
  end

  private

  def resource
    Issue.find(params[:id])
  end

  def related_person
    resource.person_id
  end

  def build_eager_load_list
    [
      *Issue::eager_issue_entities,
      [observations: [:observation_reason]],
      [person: Person::eager_person_entities]
    ]
  end
end
