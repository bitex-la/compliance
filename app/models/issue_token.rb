class IssueToken < ApplicationRecord
  belongs_to :issue
  has_many :observations, through: :issue

  before_create do
    self.token = Digest::SHA256.hexdigest SecureRandom.hex
    self.valid_until = 30.days.from_now
  end

  def self.find_by_token!(token)
    issue_token = find_by!(token: token)
    raise IssueTokenNotValidError if issue_token.valid_until < Time.current

    issue_token
  end
end

class IssueTokenNotValidError < StandardError; end
