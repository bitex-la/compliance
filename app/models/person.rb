class Person < ApplicationRecord
  include Loggable
  
  HAS_MANY = %i{
    issues
    domiciles
    identifications
    natural_dockets
    legal_entity_dockets
    fund_deposits
    allowances
    phones
    emails
    notes
    argentina_invoicing_details
    chile_invoicing_details
    affinities
    risk_scores
    attachments
  }.each do |relationship|
    has_many relationship
  end

  has_many :comments, as: :commentable
  accepts_nested_attributes_for :comments, allow_destroy: true

  enum risk: %i(low medium high)

  def natural_docket
    if self.enabled
      natural_dockets.current.first
    else
      return nil if issues.blank?
      issues.last.natural_docket_seed
    end
  end

  def legal_entity_docket
    if self.enabled
      legal_entity_dockets.current.first
    else
      return nil if issues.blank?
      issues.last.legal_entity_docket_seed
    end
  end

  def person_email
    if self.enabled
      return nil if emails.blank?
      emails.first.address
    else
      return nil if issues.blank?
      return nil if issues.last.email_seeds.blank?
      issues.last.email_seeds.first.address
    end
  end

  def is_a_natural_person?
    if self.enabled
      !natural_dockets.current.blank?
    else
      return false if issues.blank?
      !issues.last.natural_docket_seed.blank?
    end
  end

  def is_a_legal_entity?
    if self.enabled
      !legal_entity_dockets.current.blank?
    else
      return false if issues.blank?
      !issues.last.legal_entity_docket_seed.blank?
    end
  end

  def name
    "#{id}"
  end

  def fruits
    domiciles.current +
    identifications.current +
    natural_dockets.current +
    legal_entity_dockets.current +
    fund_deposits.current +
    allowances.current +
    phones.current + 
    emails.current + 
    affinities.current +
    argentina_invoicing_details.current + 
    chile_invoicing_details.current +
    notes.current
  end

  private

  def self.eager_person_entities
    entities = []
    HAS_MANY
      .reject{|x| [:attachments, :issues].include? x}
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
      :fund_deposit_seeds,
      :observations
    ])
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
      :fund_deposits,
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
