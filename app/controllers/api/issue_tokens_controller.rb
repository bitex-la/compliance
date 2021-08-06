class Api::IssueTokensController < ApplicationController
  skip_before_action :verify_authenticity_token
  include ApiResponse

  def show
    issue_token = IssueToken.includes(
      issue: [*Issue.eager_issue_entities_observations]
    ).find_by(token: params[:token])
    jsonapi_response issue_token.issue, include: params[:include] || Issue.included_for
  end

  def update
    mapper =
      JsonapiMapper.doc_unsafe!(
        params.permit!.to_h,
        [:natural_docket_seeds],
        issues: [id: params[:id]],
        natural_docket_seeds: [observations: [:reply], attachments: []]
      )

    return jsonapi_422 unless mapper.data

    if mapper.save_all
      jsonapi_response(
        mapper.data,
        { include: params[:include] || Issue.included_for }, 200
      )
    else
      json_response mapper.all_errors, 422
    end
  end
end
