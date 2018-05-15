class Api::SingleResourceIssueJsonApiSyncController < Api::IssueJsonApiSyncController
  def index
    jsonapi_response [get_resource(scope)]
  end

  def create
    if resource = get_resource(scope)
      json_response({error: "Cant create more than one"}, 422)
    end
    super
  end
end
