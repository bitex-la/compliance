class Issue < ApplicationRecord
  include AASM
  include Loggable
  StaticModels::BelongsTo

  belongs_to :person, optional: true
  validates :person, presence: true
  belongs_to :reason, class_name: "IssueReason"

  has_many :issue_taggings
  has_many :tags, through: :issue_taggings
  accepts_nested_attributes_for :issue_taggings, allow_destroy: true

  ransack_alias :state, :aasm_state

  ransacker :reason_code, formatter: proc { |v| IssueReason.find_by_code(v.to_sym)&.id } do |parent|
    parent.table[:reason_id]
  end

  before_validation do
    self.defer_until ||= Date.current
    self.reason ||= IssueReason.further_clarification
  end

  after_save :sync_observed_status
  after_save :log_if_needed
  after_save{ person.expire_action_cache }

  validate :defer_until_cannot_be_in_the_past

  def defer_until_cannot_be_in_the_past
    validation_date = created_at.try(:to_date) || Date.current
    return if defer_until >= validation_date

    errors.add(:defer_until, "can't be in the past")
  end

  validate :reason_cannot_change

  def reason_cannot_change
    return unless reason_id_changed? && persisted?
    errors.add(:reason, "change reason is not allowed!")
  end

  belongs_to :lock_admin_user, class_name: "AdminUser", foreign_key: "lock_admin_user_id", optional: true
  validate :locked_issue_cannot_changed

  include PersonScopeable

  def locked_issue_cannot_changed
    return unless locked
    return if lock_expired?
    return if locked_by_me?
    errors.add(:issue, "changes in locked issues are not allowed!")
  end

  def locked_by_me?
    lock_admin_user == AdminUser.current_admin_user
  end

  def self.lock_expiration_interval_minutes
    value = Settings.dig('lock_issues', 'expiration_interval_minutes') || 15
    value.minutes
  end

  def lock_issue!(with_expiration=true)
    with_lock do
      next false if locked? && !locked_by_me? && !lock_expired?
      self.locked = true
      self.lock_admin_user = AdminUser.current_admin_user
      self.lock_expiration = with_expiration ? Issue.lock_expiration_interval_minutes.from_now : nil
      save!(:validate => false)
      true
    end
  end

  def renew_lock!
    with_lock do
      next false unless locked_by_me?
      next false if lock_expired?
      self.lock_expiration = Issue.lock_expiration_interval_minutes.from_now
      save!(:validate => false)
      true
    end
  end

  def unlock_issue!
    with_lock do
      next false unless locked?
      next false unless locked_by_me?
      next false if lock_expired?
      self.locked = false
      self.lock_admin_user = nil
      self.lock_expiration = nil
      save!(:validate => false)
      true
    end
  end

  def lock_remaining_minutes
    return -1 if lock_expiration.nil?
    ((lock_expiration - DateTime.now.utc) / 60).ceil
  end

  def sync_observed_status
    observe! if may_observe? && has_open_observations? && aasm_state != "observed"
    answer! if may_answer? && observations.any? && !has_open_observations? && aasm_state != "answered"
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

  has_many :workflows
  accepts_nested_attributes_for :workflows, allow_destroy: true

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

  scope :active, ->(yes=true){
    current.active_states(yes)
  }

  scope :active_states, ->(yes=true){
    where("issues.aasm_state #{'NOT' unless yes} IN (?)",
      %i{draft new observed answered}
    )
  }

  scope :future_all, -> {
    where('defer_until > ?', Date.current)
  }

  scope :future, -> {
    active_states.where('defer_until > ?', Date.current)
  }

  scope :current, -> {
    where('defer_until <= ?', Date.current)
  }

  def self.ransackable_scopes(auth_object = nil)
    %i(active by_person_type by_person_tag)
  end

  def self.ransackable_scopes_skip_sanitize_args
    %i(by_person_tag)
  end

  scope :by_person_type, -> (type) {
    if type == "natural"
      left_outer_joins(:natural_docket_seed)
        .left_outer_joins(:person =>  :natural_dockets)
        .where("natural_docket_seeds.id is not null or natural_dockets.id is not null")
    elsif type == "legal"
      left_outer_joins(:legal_entity_docket_seed)
        .left_outer_joins(:person =>  :legal_entity_dockets)
        .where("legal_entity_docket_seeds.id is not null or legal_entity_dockets.id is not null")
    end
  }

  scope :by_person_tag, -> (*tags) {
    left_outer_joins(:person => :person_taggings)
      .where("person_taggings.tag_id IN (?)", tags)
  }

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
      transitions from: [:draft, :new], to: :new

      after do
        refresh_person_country_tagging!
      end
    end

    event :observe do
      transitions  from: [:draft, :new, :answered, :observed], to: :observed
    end

    event :answer do
      # Admins and migrations may create "already answered" observations.
      transitions from: [:observed, :draft, :new, :answered], to: :answered

      after do
        log_state_change(:answer_issue) if aasm.from_state != :answered
      end
    end

    event :dismiss do
      transitions from: [:draft, :new, :answered, :observed, :dismissed], to: :dismissed

      after do
        log_state_change(:dismiss_issue) if aasm.from_state != :dismissed
      end
    end

    event :reject do
      transitions from: [:draft, :new, :observed, :answered, :rejected], to: :rejected

      after do
        if aasm.from_state != :rejected
          person.reject! if reason == IssueReason.new_client
          log_state_change(:reject_issue)
        end
      end
    end

    event :approve do
      before do
        if aasm.from_state != :approved
          fulfil_affinity_relationships!
          harvest_all!
        end
      end

      transitions from: [:draft, :new, :answered, :approved], to: :approved, guard: :all_workflows_performed?

      after do
        if aasm.from_state != :approved
          person.enable! if reason == IssueReason.new_client
          log_state_change(:approve_issue)
          refresh_person_country_tagging!
        end
      end
    end

    event :abandon do
      transitions from: [:draft, :new, :observed, :answered, :abandoned], to: :abandoned

      after do
        log_state_change(:abandon_issue) if aasm.from_state != :abandoned
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

  def all_workflows_performed?
    return true if workflows.empty?
    workflows.all? {|workflow| workflow.performed?}
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
    # We never want to risk losing fruits for harvesting an old issue instance.
    # Old instances shouldn't happen in prod, mostly in specs, but just in case.
    reload
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

  def refresh_person_country_tagging!
    if argentina_invoicing_detail_seed
      person.refresh_person_country_tagging!('AR')
    end

    if chile_invoicing_detail_seed
      person.refresh_person_country_tagging!('CL')
    end
  end

  def fulfil_affinity_relationships!
    return unless affinity_seeds&.first&.affinity_kind == AffinityKind.find_by_code(:same_person)

    Util::AffinityFulfilment.call(affinity_seeds)
  end

  private

  def lock_expired?
    return false if lock_expiration.nil?
    DateTime.now >= lock_expiration
  end

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
      :'person.affinities.attachments',
      :'person.allowances',
      :'person.allowances.attachments',
      :'person.fund_deposits',
      :'person.fund_deposits.attachments',
      :'person.fund_withdrawals',
      :'person.fund_withdrawals.attachments',
      :'person.sent_transfers',
      :'person.sent_transfers.attachments',
      :'person.received_transfers',
      :'person.received_transfers.attachments',
      :'person.risk_scores',
      :'person.risk_scores.attachments',
      :natural_docket_seed,
      :'natural_docket_seed.attachments',
      :legal_entity_docket_seed,
      :'legal_entity_docket_seed.attachments',
      :argentina_invoicing_detail_seed,
      :'argentina_invoicing_detail_seed.attachments',
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
      :'identification_seeds.attachments',
      :observations,
      :'observations.observation_reason',
      :tags
    ]
  end
end
