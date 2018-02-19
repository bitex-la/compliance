class NaturalDocketSeed < ApplicationRecord
  belongs_to :issue
  belongs_to :natural_docket, optional: true

  has_many :attachments, as: :seed_to
  
  scope :current, ->(person) { where(person: person, replaced_by_id: nil) }
end
