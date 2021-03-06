class Workflow < ApplicationRecord
  include AASM
  include Loggable
  
  def self.scopes
    %i(robot admin)
  end

  enum scope: scopes

  ransack_alias :state, :aasm_state

  belongs_to :issue
  has_many :tasks
  accepts_nested_attributes_for :tasks, allow_destroy: true

  before_destroy :destroy_tasks

  def destroy_tasks
    tasks.destroy_all
  end

  validates :workflow_type, presence: true
  validates :scope, inclusion: { in: scopes }

  # We add this default_scope to allow others default_scopes
  # to cascade and apply admin taggings rules to the current query
  default_scope { joins(:issue) }

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
      transitions from: [:new, :started], to: :started, guard: :lock_issue!
    end

    event :fail do
      transitions from: [:started, :failed], to: :failed
    end

    event :dismiss do
      transitions from: [:new, :started, :dismissed], to: :dismissed
    end

    event :finish do
      transitions from: [:started, :performed], to: :performed, guard: :all_task_in_final_state?
      after do 
        issue.unlock_issue! if aasm.from_state != :performed
      end
    end
  end

  def lock_issue!
    issue.lock_issue!(false)
  end

  def name
    "Workflow ##{id} - #{workflow_type}"
  end

  def state
    aasm_state
  end

  def all_task_in_final_state?
    tasks.all? { |task| task.performed? || task.failed? }
  end

  def all_tasks_performed?
    tasks.all?(&:performed?)
  end

  def any_task_failed?
    tasks.any? { |task| task.failed? && !task.can_retry? }
  end

  def completed_tasks
    tasks.select(&:performed?)
  end

  def completness_ratio
    return 0 if tasks.empty?

    (completed_tasks.count.fdiv(tasks.count) * 100).round
  end
end
