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
  belongs_to :observable, polymorphic: true, optional: true

  before_save  :check_for_answer
  after_save :preserve_previous_reply_if_not_nil
  after_commit :sync_issue_observed_status

  validate :validate_scope_integrity
  validate :validate_issue_correspondence

  default_scope { joins(:issue, issue: :person) }

  def self.ransackable_scopes(auth_object = nil)
    %i(by_issue_reason)
  end

  def self.ransackable_scopes_skip_sanitize_args
    %i(by_issue_reason)
  end

  scope :admin_pending, -> { 
    joins(:issue)
    .where.not(issues: {aasm_state: ['abandoned', 'dismissed', 'rejected']})
    .where(scope: 'admin', aasm_state: 'new')
      .includes(:issue, :observation_reason)
  } 

  scope :robot_pending, -> { 
    joins(:issue)
    .where.not(issues: {aasm_state: ['abandoned', 'dismissed', 'rejected']})
    .where(scope: 'robot', aasm_state: 'new')
      .includes(:issue, :observation_reason)
  } 

  scope :client_pending, -> { 
    joins(:issue)
    .where.not(issues: {aasm_state: ['abandoned', 'dismissed', 'rejected']})
    .where(scope: 'client', aasm_state: 'new')
      .includes(:issue, :observation_reason)
  } 

  scope :by_issue_reason, -> (reason) {   
    joins(:issue) 
      .where(issues: {reason_id: reason})
  }

  scope :history, -> (issue) { 
    joins(:issue)
      .where("issues.id != ?", issue.id)
      .where("issues.person_id = ?", issue.person.id)
      .order('created_at DESC')
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

  def self.observables
    %w(domicile phone email
      affinity identification natural_docket
      risk_score legal_entity_docket allowance
      argentina_invoicing_detail chile_invoicing_detail
    ).map{|a| "#{a}_seeds" }
  end

  private

  def preserve_previous_reply_if_not_nil
    was, is = saved_changes[:reply]
    if !is && was
      self.update_column('reply', was)
    end
  end

  def validate_scope_integrity
    if scope != observation_reason.try(:scope)
      errors.add(:scope, "Observation and Observation reason scope must match")
    end
  end

  def validate_issue_correspondence
    return unless observable
    return if observable.issue == issue
    errors.add(:observable, "Issue and observable issue must match")
  end

  def self.included_for
    [:issue, :observation_reason]
  end
end
