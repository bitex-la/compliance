class IdentificationSeed < ApplicationRecord
  belongs_to :issue
  belongs_to :identification, optional: true
  has_many :attachments, as: :seed_to
end
