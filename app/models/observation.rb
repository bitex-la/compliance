class Observation < ApplicationRecord
  belongs_to :issue
  belongs_to :observation_reason

  after_create :observe_issue
  after_update :replicate_issue

  def observe_issue
    issue.observe!  
  end

  def replicate_issue
    issue.replicate! unless issue.replicated?
  end
end
