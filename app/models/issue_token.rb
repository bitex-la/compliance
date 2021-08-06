class IssueToken < ApplicationRecord
  belongs_to :issue

  before_create do
    self.token = Digest::SHA256.hexdigest SecureRandom.hex
    self.valid_until = 30.days.from_now
  end
end
