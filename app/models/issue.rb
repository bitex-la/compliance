class Issue < ApplicationRecord
  include AASM
  belongs_to :person, optional: true
  validates :person, presence: true

  HAS_ONE = %i{
    natural_docket_seed
    legal_entity_docket_seed
    argentina_invoicing_detail_seed
  }.each do |relationship|  
    has_one relationship, required: false
    accepts_nested_attributes_for relationship, allow_destroy: true
  end

  HAS_MANY = %i{
    relationship_seeds
    allowance_seeds
    domicile_seeds
    identification_seeds
    phone_seeds
    email_seeds
  }.each do |relationship|
    has_many relationship
    accepts_nested_attributes_for relationship, allow_destroy: true
  end

  has_many :observations
  accepts_nested_attributes_for :observations, allow_destroy: true

  scope :recent, ->(page, per_page) { order(created_at: :desc).page(page).per(per_page) }
  
  scope :just_created, -> { where('aasm_state=?', 'new') } 
  scope :answered, -> { where('aasm_state=?', 'answered') }
  scope :reviewable, -> { just_created.or(answered) }

  aasm do
    state :new, initial: true
    state :observed
    state :answered
    state :dismissed
    state :rejected
    state :approved
    state :abandoned

    event :observe do
      transitions from: :new, to: :observed
      transitions from: :answered, to: :observed
    end

    event :answer do
      transitions from: :observed, to: :answered
    end

    event :dismiss do
      transitions from: :new, to: :dismissed
      transitions from: :answered, to: :dismissed
      transitions from: :observed, to: :dismissed
    end 

    event :reject do
      after do
        person.update(enabled: false)
      end
      transitions from: :new, to: :rejected
      transitions from: :observed, to: :rejected
      transitions from: :answered, to: :rejected
    end

    event :approve do
      after do
        person.update(enabled: true)
        harvest_all!
      end
      transitions from: :new, to: :approved
      transitions from: :answered, to: :approved 
    end 

    event :abandon do
      transitions from: :new, to: :abandoned
      transitions from: :observed, to: :abandoned
      transitions from: :answered, to: :abandoned
    end
  end

  def state
    aasm_state
  end

  def editable?
    new? || observed? || answered?
  end

  def name
    "Issue #{id} - #{state}"
  end

  def harvest_all!
    HAS_MANY.each{|assoc| send(assoc).map(&:harvest!) }
    HAS_ONE.each{|assoc| send(assoc).try(:harvest!) }
  end
end
