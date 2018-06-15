class Observation < ApplicationRecord
  include AASM
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
        Event::IssueLogger.call(
          issue, 
          'answer!',
          AdminUser.current_admin_user,
          :update_entity
        ) if issue.may_answer?
      end
    end
  end

  def check_for_answer
    answer! if reply.present? && may_answer?
  end

  def observe_issue
    Event::IssueLogger.call(
      issue, 
      'observe!', 
      AdminUser.current_admin_user,
      :update_entity
    ) unless issue.observed? 
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
end
