class Task < ApplicationRecord
  include AASM
  include Loggable
  include Parametrizable

  before_validation -> { to_underscore('task_type') }, on: [:create, :update]

  belongs_to :workflow

  ransack_alias :state, :aasm_state

  aasm do 
    state :new, initial: true
    state :started
    state :performed
    state :retried
    state :failed

    event :start do
      transitions from: :new, to: :started
      after do
        workflow.start! if workflow.may_start?
      end
    end

    event :finish do 
      transitions from: :started, to: :performed, guard: :has_an_output?
      transitions from: :retried, to: :performed, guard: :has_an_output?
    end

    event :fail do
      transitions from: :started, to: :failed
      transitions from: :retried, to: :failed
    end

    event :retry do
      transitions from: :failed, to: :retried do
        guard do
          can_retry?
        end
      end
      after do
        self.update!(current_retries: self.current_retries + 1) if can_retry?
      end
    end
  end

  def state
    aasm_state
  end

  def state=(status)
    self.aasm_state = status
  end

  def can_retry?
    current_retries < max_retries
  end

  def has_an_output?
    !output.blank?
  end
end
