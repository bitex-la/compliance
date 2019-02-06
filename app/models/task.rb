class Task < ApplicationRecord
  include AASM
  include Loggable

  belongs_to :workflow
  belongs_to :task_type

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
      transitions from: :started, to: :performed
      transitions from: :retried, to: :performed
      after do
        workflow.finish! if workflow.all_tasks_performed?
      end
    end

    event :fail do
      transitions from: :started, to: :failed
      transitions from: :retried, to: :failed
      after do
        workflow.fail! if workflow.all_tasks_failed?
      end
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
end
