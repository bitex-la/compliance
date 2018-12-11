class Observation < ApplicationRecord
  include AASM
  include Loggable
  strip_attributes

  def self.scopes
    %i(client robot admin)
  end

  enum scope: scopes

  ransacker(:scope, formatter: proc { |v| scopes[v.to_s] }) do |parent|
    parent.table["scope"]
  end

  ransack_alias :state, :aasm_state
  
  belongs_to :issue
  belongs_to :observation_reason, optional: true

  before_save  :check_for_answer
  after_commit :sync_issue_observed_status

  validate :validate_scope_integrity

  scope :admin_pending, -> { 
    joins(:issue)
    .where.not(issues: {aasm_state: ['abandoned', 'dismissed']})
    .where(scope: 'admin', aasm_state: 'new')
      .includes(:issue, :observation_reason)
  } 

  scope :robot_pending, -> { 
    joins(:issue)
    .where.not(issues: {aasm_state: ['abandoned', 'dismissed']})
    .where(scope: 'robot', aasm_state: 'new')
      .includes(:issue, :observation_reason)
  } 

  scope :client_pending, -> { 
    joins(:issue)
    .where.not(issues: {aasm_state: ['abandoned', 'dismissed']})
    .where(scope: 'client', aasm_state: 'new')
      .includes(:issue, :observation_reason)
  } 

  aasm do
    state :new, initial: true     
    state :answered
  
    event :answer do
      transitions from: :new, to: :answered
    end

    event :reset do 
      transitions from: :answered, to: :new
    end
  end

  def check_for_answer
    answer! if reply.present? && may_answer?
    reset! if !reply.present? && answered?
  end

  def sync_issue_observed_status
    issue.reload
    issue.sync_observed_status
  end

  def state
    aasm_state
  end

  def name
    "Observation##{id} #{state}: #{observation_reason.try(:name)}"
  end
  
  private

  def validate_scope_integrity
    if scope != observation_reason.try(:scope)
      errors.add(:scope, "Observation and Observation reason scope must match")
    end
  end

  def self.included_for
    [:issue, :observation_reason]
  end
end
