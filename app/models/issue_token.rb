class IssueToken < ApplicationRecord
  belongs_to :issue
  has_many :observations, -> { where(aasm_state: 'new', scope: 'client') }, through: :issue

  before_create do
    self.token = Digest::SHA256.hexdigest SecureRandom.hex
    self.valid_until = Settings.observation_token_hours.hours.from_now
  end

  def self.find_by_token!(token)
    issue_token = find_by!(token: token)
    raise IssueTokenNotValidError if issue_token.valid_until < Time.current

    issue_token
  end

  def valid_token?
    Time.now < self.valid_until
  end

  def invalidate!
    self.valid_until = Time.zone.parse('Thursday, 1 January 1970')
    save!
  end
end

class IssueTokenNotValidError < StandardError; end
