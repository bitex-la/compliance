class Person < ApplicationRecord
  HAS_MANY = %i{
    issues
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
end
