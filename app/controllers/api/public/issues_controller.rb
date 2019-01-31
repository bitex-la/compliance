class Api::Public::IssuesController < Api::Public::ApiController
  def show
    #Currently only for current issue.
    issue = Issue.includes(*build_eager_load_list).ransack(
      person_id_eq: current_person.id,
      private_eq: false,
      active: true
    ).result.first

    jsonapi_public_response issue, {include: params[:include] || Issue.public_included_for}
  end

  def complete
    issue = Issue.ransack(
      person_id_eq: current_person.id,
      state_eq: 'draft'
    ).result.first

    if issue.nil?
      return jsonapi_404
    end

    issue.complete!

    jsonapi_public_response issue.reload, include: []
  end

  private

  def build_eager_load_list
    [
      *Issue::eager_issue_public_entities,
      [public_note_seeds: Issue.eager_seed_entities],
      [public_observations: [:observation_reason]],
      [person: Person::eager_person_entities]
    ]
  end
end
