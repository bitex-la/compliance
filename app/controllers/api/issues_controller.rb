class Api::IssuesController < Api::ApiController
  def index
    page, per_page = Util::PageCalculator.call(params, 0, 3)
    issues = Issue
      .includes(*build_eager_load_list)
      .order(updated_at: :desc)
      .page(page)
      .per(per_page)

    options = {
      meta: { total_pages: (issues.count.to_f / per_page).ceil },
      include: Issue.included_for
    }
    jsonapi_response issues, options, 200
  end

  def show
    issue = Issue.preload(
      [{person: Person::eager_person_entities}], *Issue::eager_issue_entities
    ).find(params[:id])

    jsonapi_response(issue, { include: Issue.included_for }, 200)
  end

  def create
    mapper = get_issue_jsonapi_mapper
    return jsonapi_422(nil) unless mapper.data

    if mapper.save_all
      jsonapi_response mapper.data, { include: Issue.included_for }, 201
    else
      json_response mapper.all_errors, 422
    end
  end

  def update
    issue = Issue.preload(
      [{person: Person::eager_person_entities}], *Issue::eager_issue_entities
    ).find(params[:id])

    mapper = get_issue_jsonapi_mapper(issue.id)
    return jsonapi_422(nil) unless mapper.data

    if mapper.save_all
      jsonapi_response(mapper.data, { include: Issue.included_for }, 200)
    else
      json_response(mapper.all_errors, 422)
    end
  end

  Issue.aasm.events.map(&:name).each do |action|
    define_method(action) do
      issue = Issue.find(params[:id])
      begin
        issue.aasm.fire!(action)
        jsonapi_response(issue, {}, 200)
      rescue AASM::InvalidTransition => e
        json_response({errors: ["invalid transition"]}, 422)
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

  def get_issue_jsonapi_mapper(issue_id = nil)
    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [ :people ],
      issues: [ :person, id: issue_id ]
  end
end
