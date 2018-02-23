class Identification < ApplicationRecord
  belongs_to :person

  has_one :identification_seed, required: false
  has_many :attachments, as: :seed_to

  scope :current, ->(person) { where(person: person, replaced_by_id: nil) }
end
