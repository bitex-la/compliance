class Api::Public::IssuesController < Api::Public::ApiController
  def show
    #Currently only for current issue.
    issue = Issue.includes(*build_eager_load_list).ransack(
      person_id_eq: current_person.id,
      private_eq: false,
      active: true
    ).result

    jsonapi_response issue, {include: params[:include] || Issue.included_for}
  end

  def complete
    issue = Issue.ransack(
      person_id_eq: current_person.id,
      state_eq: 'draft'
    ).result.first

    if issue.nil?
      return render nothing: true, status: 404
    end

    issue.complete!

    jsonapi_response issue.reload, include: []
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
