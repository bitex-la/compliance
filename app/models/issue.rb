class Issue < ApplicationRecord
  include AASM
  belongs_to :person, optional: true
  validates :person, presence: true

  HAS_ONE = %i{
    domicile_seed
    natural_docket_seed
    legal_entity_docket_seed
    identification_seed
  }.each do |relationship|  
    has_one relationship, required: false
    accepts_nested_attributes_for relationship, allow_destroy: true
  end

  HAS_MANY = %i{
    relationship_seeds
    allowance_seeds
  }.each do |relationship|
    has_many relationship
    accepts_nested_attributes_for relationship, allow_destroy: true
  end

  has_many :observations
  accepts_nested_attributes_for :observations, allow_destroy: true

  scope :recent, ->(page, per_page) { order(created_at: :desc).page(page).per(per_page) }
  
  scope :just_created, -> { where('aasm_state=?', 'new') } 
  scope :replicated, -> { where('aasm_state=?', 'replicated') }
  scope :reviewable, -> { just_created.or(replicated) }

  aasm do
    state :new, :initial => true
    state :observed
    state :replicated
    state :dismissed
    state :rejected
    state :accepted
    state :abandoned

    event :observe do
      transitions from: :new, to: :observed
      transitions from: :replicated, to: :observed
    end

    event :replicate do
      transitions from: :observed, to: :replicated
    end

    event :dismiss do
      transitions from: :new, to: :dismissed
      transitions from: :replicated, to: :dismissed
      transitions from: :observed, to: :dismissed
    end 

    event :reject do
      transitions from: :new, to: :rejected
      transitions from: :observed, to: :rejected
      transitions from: :replicated, to: :rejected
    end

    event :accept do
      transitions from: :new, to: :accepted
      transitions from: :replicated, to: :accepted 
    end 

    event :abandon do
      transitions from: :new, to: :abandoned
      transitions from: :observed, to: :abandoned
      transitions from: :replicated, to: :abandoned
    end
 end

  def get_seeds
    seeds = [] 
    seeds << identification_seed if identification_seed.present?
    seeds << natural_docket_seed if natural_docket_seed.present?
    seeds << legal_entity_docket_seed if legal_entity_docket_seed.present?
    seeds += relationship_seeds 
    seeds += allowance_seeds  
    seeds << domicile_seed if domicile_seed.present?
    seeds
  end

  def state
    aasm_state
  end
end
