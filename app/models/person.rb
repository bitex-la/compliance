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
  }.each do |relationship|
    has_many relationship
  end

  has_many :comments, as: :commentable
  accepts_nested_attributes_for :comments, allow_destroy: true
  
  enum risk: %i(low medium high)

  def natural_docket
    natural_dockets.current.first
  end

  def name
    "#{id}"
  end
end
