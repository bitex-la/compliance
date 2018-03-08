class Observation < ApplicationRecord
  include AASM
  enum scope: %i(client robot admin)
  
  belongs_to :issue
  belongs_to :observation_reason

  before_save  :check_for_answer
  after_create :observe_issue

  validate :validate_scope_integrity

  scope :admin_pending, -> { where(scope: 'admin') } 

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
    issue.observe!  
  end

  private

  def validate_scope_integrity
    return true if observation_reason.nil?
    if scope != observation_reason.scope
      errors.add("Observation and Observation reason scope must match")
    end
  end
end
