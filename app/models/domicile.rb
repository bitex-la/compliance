class Domicile < ApplicationRecord
  belongs_to :person
  has_one :domicile_seed, required: false
  has_many :attachments, as: :seed_to

  scope :current, ->(person) { where(person: person, replaced_by_id: nil) }
end
