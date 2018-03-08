class Person < ApplicationRecord
  HAS_MANY = %i{
    issues
    domiciles
    identifications
    natural_dockets
    legal_entity_dockets
    allowances
  }.each do |relationship|
    has_many relationship
  end

  has_many :comments, as: :commentable
  enum risk: %i(low medium high)

  def natural_docket
    natural_dockets.current.first
  end

  def name
    "#{id}"
  end
end
