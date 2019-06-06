class Issue < ApplicationRecord
  include AASM
  include Loggable
  belongs_to :person, optional: true
  validates :person, presence: true

  ransack_alias :state, :aasm_state

  before_validation do 
    self.defer_until ||= Date.today
  end

  after_save :sync_observed_status
  after_save :log_if_needed
  validate :defer_until_cannot_be_in_the_past

  def defer_until_cannot_be_in_the_past
    validation_date = created_at.try(:to_date) || Date.today
    return if defer_until >= validation_date
    errors.add(:defer_until, "can't be in the past")
  end

  def sync_observed_status
    observe! if may_observe? && has_open_observations?
    answer! if may_answer? && observations.any? && !has_open_observations?
  end

  def log_if_needed
    last_logged = EventLog
      .where(entity: self, verb_id: EventLogKind.send(:observe_issue).id)
      .last

    if has_open_observations? 
      last_obv = observations.where(aasm_state: 'new').last
      if !last_logged
        log_state_change(:observe_issue)
      elsif last_logged.updated_at < last_obv.updated_at
        log_state_change(:observe_issue)
      end
    end
  end

  HAS_ONE = %i{
    natural_docket_seed
    legal_entity_docket_seed
    argentina_invoicing_detail_seed
    chile_invoicing_detail_seed
  }.each do |relationship|
    has_one relationship, required: false
  end

  accepts_nested_attributes_for :legal_entity_docket_seed, allow_destroy: true,
    reject_if: proc { |attr| attr['commercial_name'].blank? && attr['legal_name'].blank? }
   accepts_nested_attributes_for :argentina_invoicing_detail_seed, allow_destroy: true,
    reject_if: proc { |attr| attr['tax_id'].blank? }
   accepts_nested_attributes_for :chile_invoicing_detail_seed, allow_destroy: true,
    reject_if: proc { |attr| attr['tax_id'].blank? }
   accepts_nested_attributes_for :natural_docket_seed, allow_destroy: true,
    reject_if: proc { |attr| attr['first_name'].blank? && attr['last_name'].blank? }

  HAS_MANY = %i{
    allowance_seeds
    domicile_seeds
    identification_seeds
    phone_seeds
    email_seeds
    note_seeds
    affinity_seeds
    risk_score_seeds
  }.each do |relationship|
    has_many relationship
    accepts_nested_attributes_for relationship, allow_destroy: true
  end

  has_many :observations
  accepts_nested_attributes_for :observations,
    reject_if: proc { |attr| attr['scope'].blank? || attr['observation_reason_id'].blank? }

  scope :with_relations, -> {
    includes(
      :person,
      *HAS_MANY,
      *HAS_ONE
    ) 
  }

  {
    draft: :draft,
    fresh: :new,
    answered: :answered,
    observed: :observed
  }.each do |k,v| 
    scope k, -> { current.with_relations.where('issues.aasm_state=?', v) }  
  end

  scope :changed_after_observation, -> {
    where = []
    Issue::HAS_ONE.each do |r|
      where << "#{r.to_s.pluralize}.updated_at > observations.created_at"
    end
    Issue::HAS_MANY.each do |r|
      where << "#{r}.updated_at > observations.created_at"
    end

    observed
      .current
      .eager_load(*[:observations, *Issue::HAS_ONE, *Issue::HAS_MANY])
      .where(where.join(" OR "))
      .where("observations.reply IS NULL OR observations.reply = ''")
  }

  scope :active, ->(yes=true){
    current.active_states
  }

  scope :active_states, ->(yes=true){
    where("aasm_state #{'NOT' unless yes} IN (?)",
      %i{draft new observed answered}
    )
  }

  scope :future_all, -> { 
    where('defer_until > ?', Date.today)
  }

  scope :future, -> { 
    active_states.where('defer_until > ?', Date.today)
  }
  
  scope :current, -> { 
    where('defer_until <= ?', Date.today)
  }

	def self.ransackable_scopes(auth_object = nil)
	  %i(active)
  end

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
      
      # Admins and migrations may create "already answered" observations.
      transitions from: :draft, to: :answered
      transitions from: :new, to: :answered

      after do 
        log_state_change(:answer_issue)
      end
    end

    event :dismiss do
      transitions  from: :draft, to: :dismissed
      transitions from: :new, to: :dismissed
      transitions from: :answered, to: :dismissed
      transitions from: :observed, to: :dismissed
      after do 
        log_state_change(:dismiss_issue)
      end
    end

    event :reject do
      after do
        person.update(enabled: false) unless person.nil?
      end
      transitions from:  :draft, to: :rejected
      transitions from: :new, to: :rejected
      transitions from: :observed, to: :rejected
      transitions from: :answered, to: :rejected
      after do 
        log_state_change(:reject_issue)
      end
    end

    event :approve do
      before{ harvest_all! }
      after do
        person.update(enabled: true)
        log_state_change(:approve_issue)
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
      after do 
        log_state_change(:abandon_issue)
      end
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
    "案 #{id} #{state.titleize} for #{person.name}"
  end

  def harvest_all!
    HAS_MANY.each{|assoc| send(assoc).map(&:harvest!) }
    HAS_ONE.each{|assoc| send(assoc).try(:harvest!) }
  end

  def add_seeds_replacing(fruits)
    fruits.each do |fruit|
      next if fruit.person != self.person

      attrs = fruit.attributes.except(
        *%w(id created_at updated_at person_id issue_id replaced_by_id)
      )
      seed = Garden::Naming.new(fruit.class.name).seed.constantize.new(attrs)
      seed.issue = self
      seed.replaces = fruit if seed.respond_to? :replaces
      seed.copy_attachments = true
      seed.save!
    end
  end

  def has_open_observations?
    observations.where(aasm_state: 'new').any?
  end

  def all_attachments
    all = []
    HAS_MANY.each do |assoc|
      send(assoc).map do |o|
        next if o.nil?
        all += o.fruit_id ? o.fruit.attachments : o.attachments
      end
    end

    HAS_ONE.each do |assoc|
      o = send(assoc)
      next if o.nil?
      all += o.fruit_id ? o.fruit.attachments : o.attachments
    end

    all
  end

  def self.restricted_actions
    %i(
      complete
      approve
      abandon
      dismiss
      reject
    )
  end

  def all_seeds
    HAS_MANY.map{|a| send(a).try(:to_a) }.compact.flatten +
      HAS_ONE.map{|a| send(a) }.compact
  end

  def for_person_type
    return person.person_type if person && person.person_type 

    if natural_docket_seed_id
      :natural_person
    elsif legal_entity_docket_seed_id
      :legal_entity
    end
  end

  private  

  def log_state_change(verb)
    EventLog.log_entity!(self, AdminUser.current_admin_user, EventLogKind.send(verb))
  end

  def self.eager_issue_entities
    entities = []
    (HAS_ONE + HAS_MANY).map(&:to_s).each do |seed|
      entities.push([seed => eager_seed_entities])
    end
    entities
  end

  def self.eager_seed_entities
    [:person, :fruit , attachments:[:attached_to_fruit, :attached_to_seed]]
  end

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
