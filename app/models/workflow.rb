class Workflow < ApplicationRecord
  include AASM
  include Loggable

  validates :workflow_kind, inclusion: { in: WorkflowKind.all }
  ransackable_static_belongs_to :workflow_kind

  def self.scopes
    %i(robot admin)
  end

  enum scope: scopes

  ransack_alias :state, :aasm_state

  belongs_to :issue
  has_many :tasks
  accepts_nested_attributes_for :tasks, allow_destroy: true

  scope :running, -> {
    joins(:issue)
    .where(aasm_state: 'started')
  }

  scope :failing, -> {
    joins(:issue)
    .where(aasm_state: 'failed')
  }

  aasm do 
    state :new, initial: true
    state :started
    state :performed
    state :failed
    state :dismissed

    event :start do 
      transitions from: :new, to: :started
    end

    event :fail do
      transitions from: :started, to: :failed
    end

    event :dismiss do
      transitions from: :new, to: :dismissed
      transitions from: :started, to: :dismissed
    end

    event :finish do
      transitions from: :started, to: :performed do 
        guard do 
          all_tasks_performed?
        end
      end
    end
  end

  def name
   "Workflow ##{id} - #{workflow_kind}"
  end

  def state
    aasm_state
  end

  def state=(status)
    self.aasm_state = status
  end

  def all_tasks_performed?
    tasks.all? {|task| task.performed?}
  end

  def all_tasks_failed?
    tasks.all? {|task| task.failed? && !task.can_retry?}
  end

  def completed_tasks
    tasks.select{|x| x.performed?}
  end

  def completness_ratio
    return 0 if tasks.empty?
    (completed_tasks.count.fdiv(tasks.count) * 100).round
  end
end
