module VerifyIssueToken
  extend ActiveSupport::Concern

  def check_validity_token(token, observation_id)
    IssueToken
      .includes(:observations)
      .where(observations: { id: observation_id }).find_by_token!(token)
  end

  def issue_token
    params[:issue_token_id].present?
  end
end
