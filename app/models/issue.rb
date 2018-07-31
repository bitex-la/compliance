class Issue < ApplicationRecord
  include AASM
  include Loggable
  belongs_to :person, optional: true
  validates :person, presence: true

  after_create :fill_seeds_if_apply

  ORIGINABLE_FRUITS = %i{
    natural_dockets
    legal_entity_dockets
    argentina_invoicing_details
    chile_invoicing_details
    domiciles 
    identifications
    phones 
    emails 
    allowances
  }

  HAS_ONE = %i{
    natural_docket_seed
    legal_entity_docket_seed
    argentina_invoicing_detail_seed
    chile_invoicing_detail_seed
  }.each do |relationship|
    has_one relationship, required: false
  end

  accepts_nested_attributes_for :legal_entity_docket_seed, allow_destroy: true,
    reject_if: proc { |attr| attr['commercial_name'].blank? || attr['legal_name'].blank? }

  accepts_nested_attributes_for :argentina_invoicing_detail_seed, allow_destroy: true,
    reject_if: proc { |attr| attr['tax_id'].blank? }

  accepts_nested_attributes_for :chile_invoicing_detail_seed, allow_destroy: true,
    reject_if: proc { |attr| attr['tax_id'].blank? }

  accepts_nested_attributes_for :natural_docket_seed, allow_destroy: true,
    reject_if: proc { |attr| attr['first_name'].blank? || attr['last_name'].blank? }

  HAS_MANY = %i{
    allowance_seeds
    domicile_seeds
    identification_seeds
    phone_seeds
    email_seeds
    note_seeds
    affinity_seeds
    risk_score_seeds
    fund_deposit_seeds
  }.each do |relationship|
    has_many relationship
    accepts_nested_attributes_for relationship, allow_destroy: true
  end

  has_many :observations
  accepts_nested_attributes_for :observations, allow_destroy: true

  scope :recent, ->(page, per_page) { order(created_at: :desc).page(page).per(per_page) }

  scope :incomplete, -> { where('aasm_state=?', 'draft') }
  scope :just_created, -> { where('aasm_state=?', 'new') }
  scope :answered, -> { where('aasm_state=?', 'answered') }
  scope :observed, -> { where('aasm_state=?', 'observed') }
  scope :reviewable, -> { just_created.or(answered) }

  aasm do
    state :draft, initial: true
    state :new
    state :observed
    state :answered
    state :dismissed
    state :rejected
    state :approved
    state :abandoned

    event :complete do
      transitions from: :draft, to: :new
    end

    event :observe do
      transitions  from: :draft, to: :observed
      transitions from: :new, to: :observed
      transitions from: :answered, to: :observed
    end

    event :answer do
      transitions from: :observed, to: :answered
    end

    event :dismiss do
      transitions  from: :draft, to: :dismissed
      transitions from: :new, to: :dismissed
      transitions from: :answered, to: :dismissed
      transitions from: :observed, to: :dismissed
    end

    event :reject do
      after do
        person.update(enabled: false) unless person.nil?
      end
      transitions from:  :draft, to: :rejected
      transitions from: :new, to: :rejected
      transitions from: :observed, to: :rejected
      transitions from: :answered, to: :rejected
    end

    event :approve do
      after do
        person.update(enabled: true)
        harvest_all!
      end
      transitions from: :draft, to: :approved
      transitions from: :new, to: :approved
      transitions from: :answered, to: :approved
    end

    event :abandon do
      transitions from: :draft, to: :abandoned
      transitions from: :new, to: :abandoned
      transitions from: :observed, to: :abandoned
      transitions from: :answered, to: :abandoned
    end
  end

  def modifications_count
    count = 0

    HAS_ONE.each do |relation|
      count += 1 unless send(relation).nil?
    end

    HAS_MANY.each do |relation|
      count += send(relation).count unless send(relation).blank?
    end
    count
  end

  def state
    aasm_state
  end

  def state=(status)
    self.aasm_state = status
  end

  def editable?
    draft? || new? || observed? || answered?
  end

  def name
    "Issue #{id} - #{state}"
  end

  def harvest_all!
    HAS_MANY.each{|assoc| send(assoc).map(&:harvest!) }
    HAS_ONE.each{|assoc| send(assoc).try(:harvest!) }
  end

  def fill_seeds_if_apply
    ORIGINABLE_FRUITS.each do |assoc|
      if person.send(assoc).current.any? 
        fruit = person.send(assoc).current.first
        seed  = Garden::Naming.new(assoc)
          .seed.constantize.new (
            fruit.attributes.except(
              *%w(id created_at updated_at person_id issue_id replaced_by_id)
            )
          )
        seed.issue = self
        seed.replaces = fruit if seed.respond_to? :replaces
        seed.save
        fruit.attachments.each do |a|
          begin
            attachment = Attachment.new(
              document: a.document,
              attached_to_seed: seed,
              person: person
            )
            attachment.save
          rescue Exception => e 
            
          end
        end
      end
    end
  end

  private  
  def self.included_for
    [
      :person,
      :'person.identifications',
      :'person.identifications.attachments',
      :'person.domiciles',
      :'person.domiciles.attachments',
      :'person.natural_dockets',
      :'person.natural_dockets.attachments',
      :'person.legal_entity_dockets',
      :'person.legal_entity_dockets.attachments',
      :'person.argentina_invoicing_details',
      :'person.argentina_invoicing_details.attachments',
      :'person.chile_invoicing_details',
      :'person.chile_invoicing_details.attachments',
      :'person.phones',
      :'person.phones.attachments',
      :'person.emails',
      :'person.emails.attachments',
      :'person.notes',
      :'person.notes.attachments',
      :'person.affinities',
      :'person.affinities.atachments',
      :'person.allowances',
      :'person.allowances.attachments',
      :'person.fund_deposits',
      :'person.fund_deposits.attachments',
      :'person.risk_scores',
      :'person.risk_scores.attachments',
      :natural_docket_seed,
      :'natural_docket_seed.attachments',
      :legal_entity_docket_seed,
      :'legal_entity_docket_seed.attachments',
      :argentina_invoicing_detail_seed,
      :'argentina_invoicing_detail_seed.atachments',
      :chile_invoicing_detail_seed,
      :'chile_invoicing_detail_seed.attachments',
      :allowance_seeds,
      :'allowance_seeds.attachments',
      :fund_deposit_seeds,
      :'fund_deposit_seeds.attachments',
      :phone_seeds,
      :'phone_seeds.attachments',
      :email_seeds,
      :'email_seeds.attachments',
      :note_seeds,
      :'note_seeds.attachments',
      :domicile_seeds,
      :'domicile_seeds.attachments',
      :risk_score_seeds,
      :'risk_score_seeds.attachments',
      :affinity_seeds,
      :'affinity_seeds.attachments',
      :identification_seeds,
      :'identifications_seeds.attachments',
      :observations,
      :'observations.observation_reason'
    ]
  end
end
