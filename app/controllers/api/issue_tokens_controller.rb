class Api::IssueTokensController < ApplicationController
  skip_before_action :verify_authenticity_token
  include ApiResponse

  def show_by_token
    issue_token = IssueToken.includes(:observations).find_by_token!(params[:issue_token_id])
    jsonapi_response issue_token, include: 'observations'
  rescue IssueTokenNotValidError
    jsonapi_error(410, 'invalid token')
  end
end
