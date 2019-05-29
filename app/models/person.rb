class Person < ApplicationRecord
  include Loggable, StaticModels::BelongsTo

  after_save :log_if_enabled
  after_save :expire_action_cache
  
  belongs_to :regularity, class_name: "PersonRegularity"

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
    has_many relationship, -> { where("#{relationship}.replaced_by_id is NULL") }
    has_many "#{relationship}_history".to_sym, class_name: relationship.to_s.classify
  end

  HAS_MANY_PLAIN = %i{
    issues
    fund_deposits
    attachments
  }.each do |relationship|
    has_many relationship
  end

  HAS_MANY = HAS_MANY_REPLACEABLE + HAS_MANY_PLAIN

  has_many :comments, as: :commentable
  accepts_nested_attributes_for :comments, allow_destroy: true

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

  def person_email
    emails.last.try(:address)
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

  def name
    name =
      if (docket = natural_dockets.last)
        [docket.first_name, docket.last_name].join(' ')
      elsif (docket = legal_entity_dockets.last)
        docket.legal_name || docket.commercial_name
      else
        person_email
      end

    "人 #{id}: #{name}"
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
    Affinity.where("person_id = ? OR related_person_id = ?", id, id)
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
    sum, count = fund_deposits.pluck('sum(exchange_rate_adjusted_amount), count(*)').first
    
    self.regularity = PersonRegularity.all.reverse
      .find {|x| x.applies? sum,count} 

    should_log = regularity_id_changed?

    if should_log
      issue = issues.build(state: 'new')
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

  private

  def expire_action_cache
    ActionController::Base.new.expire_fragment(%r{person/show/#{self.id}})
  end

  def log_if_enabled
    was, is = saved_changes[:enabled]
    log_state_change(:enable_person) if !was && is
    log_state_change(:disable_person) if was && !is
  end

  def log_state_change(verb)
    EventLog.log_entity!(self, AdminUser.current_admin_user, EventLogKind.send(verb))
  end

  def self.eager_person_entities
    entities = []
    HAS_MANY
      .reject{|x| [:attachments, :issues, :fund_deposits].include? x}
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
