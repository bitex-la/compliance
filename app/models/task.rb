class Task < ApplicationRecord
  include AASM
  include Loggable

  belongs_to :workflow

  ransack_alias :state, :aasm_state

  validates :task_type, presence: true

  default_scope { joins(:workflow, workflow: :issue) }

  aasm do
    state :new, initial: true
    state :started
    state :performed
    state :retried
    state :failed

    event :start do
      transitions from: [:new, :started], to: :started, guard: :start_workflow!
    end

    event :finish do
      transitions from: [:started, :retried, :performed], to: :performed, guard: :has_an_output?
    end

    event :fail do
      transitions from: [:started, :retried, :failed], to: :failed
    end

    event :retry do
      transitions from: [:started, :retried], to: :retried do
        guard do
          can_retry?
        end
      end
      after do
        self.update!(current_retries: self.current_retries + 1) if can_retry?
      end
    end
  end

  def failure!
    if can_retry?
      retry!
    else
      fail!
    end
  end

  def state
    aasm_state
  end

  def can_retry?
    current_retries < max_retries
  end

  def can_execute?
    state == 'new' || (state == 'retried' && can_retry?)
  end

  def has_an_output?
    !output.blank?
  end

  private

  def start_workflow!
    return true if workflow.state == "started"
    workflow.start!
  end
end
