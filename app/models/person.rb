class Person < ApplicationRecord
  include Loggable

  after_save :log_if_enabled
  after_save :expire_action_cache
  
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
    %i{
      natural_dockets
      legal_entity_dockets
      argentina_invoicing_details
      chile_invoicing_details
      domiciles 
      identifications
      phones 
      emails 
      allowances
    }.map{|assoc| send(assoc).current.to_a }.flatten
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
    name = if docket = natural_dockets.last
      [docket.first_name, docket.last_name].join(" ")
    elsif docket = legal_entity_dockets.last
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

  private

  def expire_action_cache
    ActionController::Base.new.expire_fragment("api/people/show/#{self.id}")
  end

  def log_if_enabled
    was, is = saved_changes[:enabled]
    log_state_change(:enable_person) if !was && is
    log_state_change(:disable_person) if was && !is
  end

  def log_state_change(verb)
    Event::EventLogger.call(self, AdminUser.current_admin_user, EventLogKind.send(verb))
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
      :attachments
    ]
  end
end
