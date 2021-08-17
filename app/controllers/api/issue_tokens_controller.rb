class Api::IssueTokensController < ApplicationController
  skip_before_action :verify_authenticity_token
  include ApiResponse

  def show
    issue_token = IssueToken.includes(
      issue: Issue.eager_issue_entities_observations.flatten
    ).find_by_token!(params[:id])
    jsonapi_response issue_token,
                     include: params[:include] || Issue.included_for.map { |type| "issue.#{type}" }
  rescue IssueTokenNotValidError
    jsonapi_error(410, 'invalid token')
  end
end
