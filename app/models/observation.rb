class Observation < ApplicationRecord
  include AASM
  include Loggable
  enum scope: %i(client robot admin)
  
  belongs_to :issue
  belongs_to :observation_reason, optional: true

  before_save  :check_for_answer
  after_commit :update_issue_status

  validate :validate_scope_integrity

  scope :admin_pending, -> { 
    where(scope: 'admin', aasm_state: 'new')
      .includes(:issue, :observation_reason)
  } 

  aasm do
    state :new, initial: true
    state :answered
  
    event :answer do
      transitions from: :new, to: :answered
      after do
        issue.answer! if issue.may_answer? && !issue.has_open_observations?
      end
    end

    event :reset do 
      transitions from: :answered, to: :new
    end
  end

  def check_for_answer
    answer! if reply.present? && may_answer?
    reset! if !reply.present? && answered?
  end

  def observe_issue
    if issue.may_observe?
      issue.observe! 
    end
  end

  def update_issue_status
    if !reply.present? && note.present?
      issue.observe! if issue.may_observe?
    end
  end

  def state
    aasm_state
  end

  def name
    "##{id} #{state}"
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
