class Identification < ApplicationRecord
  belongs_to :issue, optional: true
  belongs_to :person

  has_many :identification_seeds
end
