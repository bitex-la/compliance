class Person < ApplicationRecord
  include AASM
  include Loggable
  StaticModels::BelongsTo

  after_create :log_state_new
  after_save :log_if_enabled
  after_save :log_state_changes
  after_save :expire_action_cache

  belongs_to :regularity, class_name: "PersonRegularity"

  ransack_alias :state, :aasm_state

  HAS_MANY_REPLACEABLE = %i{
    domiciles
    identifications
    natural_dockets
    legal_entity_dockets
    allowances
    phones
    emails
    notes
    argentina_invoicing_details
    chile_invoicing_details
    affinities
    risk_scores
  }.each do |relationship|
    has_many relationship, -> {
      where("#{relationship}.replaced_by_id is NULL")
      .where("#{relationship}.archived_at is NULL OR #{relationship}.archived_at > ?", Date.current)
    }

    has_many "#{relationship}_history".to_sym, class_name: relationship.to_s.classify
  end

  HAS_MANY_PLAIN = %i{
    issues
    fund_deposits
    fund_withdrawals
    attachments
  }.each do |relationship|
    has_many relationship
  end

  HAS_MANY = HAS_MANY_REPLACEABLE + HAS_MANY_PLAIN

  has_many :received_transfers, :class_name => 'FundTransfer', :foreign_key => 'target_person_id'
  has_many :sent_transfers, :class_name => 'FundTransfer', :foreign_key => 'source_person_id'

  has_many :comments, as: :commentable
  accepts_nested_attributes_for :comments, allow_destroy: true

  has_many :person_taggings
  has_many :tags, through: :person_taggings
  accepts_nested_attributes_for :person_taggings, allow_destroy: true

  validate :person_tag_must_be_managed_by_admin

  def person_tag_must_be_managed_by_admin
    return unless (admin_user = AdminUser.current_admin_user)
    return if tags.empty? ||
      tags.any? { |t| admin_user.can_manage_tag?(t) }

    errors.add(:person, 'Person tags not allowed')
  end

  def replaceable_fruits
    %i[
      natural_dockets
      legal_entity_dockets
      argentina_invoicing_details
      chile_invoicing_details
      domiciles
      identifications
      phones
      emails
      allowances
    ].map { |assoc| send(assoc).current.to_a }.flatten
  end

  enum risk: %i(low medium high)

  def self.default_scope
    return unless (tags = AdminUser.current_admin_user&.active_tags.presence)

    where(%{people.id NOT IN (SELECT person_id FROM person_taggings)
      OR people.id IN (SELECT person_id FROM person_taggings WHERE tag_id IN (?))
      }, tags).distinct
  end

  def natural_docket
    natural_dockets.last
  end

  def legal_entity_docket
    legal_entity_dockets.last
  end

  def person_type
    if natural_dockets.any?
      :natural_person
    elsif legal_entity_dockets.any?
      :legal_entity
    end
  end

  def self.person_types
    %i(natural legal)
  end

  scope :by_person_type, -> (type){
    {
      natural: left_outer_joins(:natural_dockets)
        .left_outer_joins(:issues =>  :natural_docket_seed)
        .where("natural_docket_seeds.id is not null or natural_dockets.id is not null")
        .distinct,
      legal: left_outer_joins(:legal_entity_dockets)
        .left_outer_joins(:issues =>  :legal_entity_docket_seed)
        .where("legal_entity_docket_seeds.id is not null or legal_entity_dockets.id is not null")
        .distinct
    }[type.to_sym]
  }

  scope :with_relations, -> {
    includes(
      nil
    )
  }

  {
    fresh: :new,
    enabled: :enabled,
    disabled: :disabled,
    rejected: :rejected
  }.each do |k, v|
    scope k, -> { with_relations.where('people.aasm_state=?', v) }
  end

  def self.ransackable_scopes(auth_object = nil)
    %i(by_person_type)
  end

  def name
    "(#{id}) #{person_info_name || person_info_email}"
  end

  def person_info
    [ "(#{id})",
      person_info_name,
      person_info_email,
      person_info_phone
    ].join(" ").strip
  end

  def person_info_name
    case person_type
      when :natural_person
        "☺: #{natural_dockets.last.name_body}"
      when :legal_entity
        "🏭: #{legal_entity_dockets.last.name_body}"
      else
        if found = issues.map(&:natural_docket_seed).compact.last
          "*☺: #{found.name_body}"
        elsif found = issues.map(&:legal_entity_docket_seed).compact.last
          "*🏭: #{found.name_body}"
        end
    end
  end

  def person_info_email
    template = "%s✉: %s"

    if found = emails.last.try(:address)
      template % [nil, found]
    elsif found = issues.all.map{|i| i.email_seeds.first&.address }
      .compact.last
      template % ['*', found]
    end
  end

  def person_info_phone
    phone, from_seed = if found = phones.last
      found
    elsif found = issues.all.map{|i| i.phone_seeds.first }.compact.last
      [found, "*"]
    end

    return unless phone

    has_whatsapp = phone.has_whatsapp ? "✓" : "⨯"
    "#{from_seed}☎: #{phone.number} #{from_seed}WA: #{has_whatsapp}"
  end

  def fruits
    domiciles.current +
      identifications.current +
      natural_dockets.current +
      legal_entity_dockets.current +
      allowances.current +
      phones.current +
      emails.current +
      affinities.current +
      argentina_invoicing_details.current +
      chile_invoicing_details.current +
      notes.current
  end

  def archived_fruits
    Domicile.archived(self) +
      Identification.archived(self) +
      NaturalDocket.archived(self) +
      LegalEntityDocket.archived(self) +
      Allowance.archived(self) +
      Phone.archived(self) +
      Email.archived(self) +
      Affinity.archived(self) +
      ArgentinaInvoicingDetail.archived(self) +
      ChileInvoicingDetail.archived(self) +
      Note.archived(self)
  end

  def all_attachments
    attachments
      .where("attached_to_seed_id is null AND attached_to_fruit_id is not null")
  end

  def all_current_attachments
    all_attachments.select do |a|
      a.attached_to_fruit.replaced_by.nil?
    end.compact
  end

  def all_observations
    issues.includes(observations: :observation_reason)
      .where.not(aasm_state: ['dismissed', 'abandoned'])
      .map{|o| o.observations.to_a }.flatten
  end

  def all_affinities
    Affinity.where(person: self).or(Affinity.where(related_person: self))
  end

  def public_notes
    Note.where(person: self, public: true)
  end

  def email_for_export
    email = emails.find { |e| e.email_kind == EmailKind.authentication } ||
            emails.last
    email&.address
  end

  def self.suggest(keyword, page = 1, per_page = 20)
    result = Array.new
    [
      {entity: 'Person', field: 'id', matcher: 'eq', id: 'id', suggestion: ['name', 'id']},
      {entity: 'Email', field: 'address', matcher: 'cont', id: 'person_id', suggestion: ['person.name', 'address']},
      {entity: 'EmailSeed', field: 'address', matcher: 'cont', id: 'issue.person_id', suggestion: ['issue.person.name', 'address']},
      {entity: 'Phone', field: 'number', matcher: 'cont', id: 'person_id', suggestion: ['person.name', 'number']},
      {entity: 'PhoneSeed', field: 'number', matcher: 'cont', id: 'issue.person_id', suggestion: ['issue.person.name', 'number']},
      {entity: 'Identification', field: 'number', matcher: 'cont', id: 'person_id', suggestion: ['person.name', 'number']},
      {entity: 'IdentificationSeed', field: 'number', matcher: 'cont', id: 'issue.person_id', suggestion: ['issue.person.name', 'number']},
      {entity: 'NaturalDocket', field: 'first_name', matcher: 'cont', id: 'person_id', suggestion: ['person.name', 'first_name', 'last_name']},
      {entity: 'NaturalDocket', field: 'last_name', matcher: 'cont', id: 'person_id', suggestion: ['person.name', 'first_name', 'last_name']},
      {entity: 'NaturalDocketSeed', field: 'first_name', matcher: 'cont', id: 'issue.person_id', suggestion: ['issue.person.name', 'first_name', 'last_name']},
      {entity: 'NaturalDocketSeed', field: 'last_name', matcher: 'cont', id: 'issue.person_id', suggestion: ['issue.person.name', 'first_name', 'last_name']}
    ].each do |d|
      result = result.concat(d[:entity].constantize
        .order(updated_at: :desc, id: :desc)
        .page(page).per(per_page)
        .send(:ransack, {"#{d[:field]}_#{d[:matcher]}" => keyword})
        .result.map{|x| {
          id: x.instance_eval(d[:id]),
          suggestion: d[:suggestion].map{|e| x.instance_eval(e)}.join(' - ')
        }})
    end
    result.uniq[0..per_page]
  end

  def refresh_person_regularity!
    sum, count = fund_deposits.pluck(Arel.sql('sum(exchange_rate_adjusted_amount), count(*)')).first

    self.regularity = PersonRegularity.all.reverse
      .find {|x| x.applies? sum,count}

    should_log = regularity_id_changed?

    if should_log
      issue = issues.build(state: 'new', reason: IssueReason.new_risk_information)
      issue.risk_score_seeds.build(
        score: regularity.code,
        provider: 'open_compliance',
        extra_info: {
          regularity_funding_amount: regularity.funding_amount.to_d,
          regularity_funding_count: regularity.funding_count,
          funding_total_amount: sum.to_d,
          funding_count: count
        }.to_json
      )
    end

    save!

    EventLog.log_entity!(self, AdminUser.current_admin_user,
      EventLogKind.update_person_regularity) if should_log
  end

  def refresh_person_country_tagging!(country)
    tag_name = "active-in-#{country}"
    tag = Tag.find_or_create_by(tag_type: :person, name: tag_name)

    AdminUser.current_admin_user&.add_tag(tag)

    PersonTagging.find_or_create_by(person: self, tag: tag)
    tags.reload
  end

  aasm do
    state :new, initial: true
    state :enabled
    state :disabled
    state :rejected

    event :enable do
      transitions from: [:new, :disabled, :rejected, :enabled], to: :enabled do
        after { self['enabled'] = true }
      end
    end

    event :disable do
      transitions from: [:enabled, :new, :rejected, :disabled], to: :disabled do
        after { self['enabled'] = false }
      end
    end

    event :reject do
      transitions from: [:new, :enabled, :disabled, :rejected], to: :rejected do
        after { self['enabled'] = false }
      end
    end
  end

  def state
    aasm_state
  end

  def enabled
    aasm_state == "enabled"
  end

  def enabled=(value)
    enable if value && may_enable?
    disable if !value && may_disable?
  end

  def generate_pdf_profile(include_affinities = false, include_risk_scores = false)
    PersonProfile.generate_pdf(self, include_affinities, include_risk_scores)
  end

  def expire_action_cache
    Rails.cache.delete_matched "*/person/show/#{self.id}/*"
  end

  private

  def log_if_enabled
    was, is = saved_changes[:enabled]
    log_state_change(:enable_person) if !was && is
    log_state_change(:disable_person) if was && !is
  end

  def log_state_changes
    log_state_change("person_#{aasm_state}".to_sym) if aasm.from_state != aasm.to_state
  end

  def log_state_new
    log_state_change(:person_new)
  end

  def log_state_change(verb)
    EventLog.log_entity!(self, AdminUser.current_admin_user, EventLogKind.send(verb))
  end

  def self.eager_person_entities
    entities = []
    HAS_MANY
      .reject{|x| [:attachments, :issues, :fund_deposits, :fund_withdrawals,
                   :received_transfers, :sent_transfers].include? x}
      .map(&:to_s).each do |fruit|
      entities.push("#{fruit}": eager_fruit_entities)
    end
    entities.push(
      :attachments,
      issues: [
      :natural_docket_seed,
      :legal_entity_docket_seed,
      :argentina_invoicing_detail_seed,
      :chile_invoicing_detail_seed,
      :allowance_seeds,
      :domicile_seeds,
      :identification_seeds,
      :phone_seeds,
      :email_seeds,
      :note_seeds,
      :affinity_seeds,
      :risk_score_seeds,
      :observations
    ])
    entities.push(fund_deposits: :attachments)
    entities.push(fund_withdrawals: :attachments)
    entities.push(received_transfers: :attachments)
    entities.push(sent_transfers: :attachments)
    entities
  end

  def self.eager_fruit_entities
    [:seed , attachments:[:attached_to_fruit, :attached_to_seed]]
  end

  def self.included_for
    [
      :issues,
      :domiciles,
      :identifications,
      :natural_dockets,
      :legal_entity_dockets,
      :allowances,
      :phones,
      :emails,
      :affinities,
      :argentina_invoicing_details,
      :chile_invoicing_details,
      :notes,
      :attachments,
      :regularity
    ]
  end
end
