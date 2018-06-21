class Observation < ApplicationRecord
  include AASM
  include Loggable
  enum scope: %i(client robot admin)
  
  belongs_to :issue
  belongs_to :observation_reason, optional: true

  before_save  :check_for_answer
  after_create :observe_issue

  validate :validate_scope_integrity

  scope :admin_pending, -> { where(scope: 'admin', aasm_state: 'new') } 

  aasm do
    state :new, initial: true
    state :answered
  
    event :answer do
      transitions from: :new, to: :answered
      after do
        issue.answer! if issue.may_answer?
      end
    end
  end

  def check_for_answer
    answer! if reply.present? && may_answer?
  end

  def observe_issue
    issue.observe! if issue.may_observe?
  end

  def state
    aasm_state
  end

  private

  def validate_scope_integrity
    if scope != observation_reason.try(:scope)
      errors.add(:scope, "Observation and Observation reason scope must match")
    end
  end

  def self.included_for
    [
      :issue,
      :observation_reason
    ]
  end
end
