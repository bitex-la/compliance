class Observation < ApplicationRecord
  enum scope: %i(client robot)
  
  belongs_to :issue
  belongs_to :observation_reason

  after_create :observe_issue
  after_update :replicate_issue

  validate :validate_scope_integrity

  def observe_issue
    issue.observe!  
  end

  def replicate_issue
    issue.replicate! unless issue.replicated? || issue.new?
  end

  private

  def validate_scope_integrity
    if(self.scope != observation_reason.scope)
      errors.add("Observation and Observation reason scope must match")
    end
  end
end
