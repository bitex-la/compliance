class Api::IssueTokensController < Api::ApiController
  before_action :require_token, only: [:show]
  include ApiResponse

  def show
    jsonapi_response IssueToken.find(params[:id])
  end

  def show_by_token
    issue_token = IssueToken.includes(:observations).find_by_token!(params[:issue_token_id])
    jsonapi_response issue_token, include: 'observations'
  rescue IssueTokenNotValidError
    jsonapi_error(410, 'invalid token')
  end
end
