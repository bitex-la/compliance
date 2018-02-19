class NaturalDocketSeed < ApplicationRecord
  belongs_to :issue
  belongs_to :natural_docket, optional: true

  has_many :attachments, as: :seed_to
  
  accepts_nested_attributes_for :attachments, :allow_destroy => true
  
  scope :current, ->(person) { where(person: person, replaced_by_id: nil) }
end
