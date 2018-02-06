class Funding < ApplicationRecord
  belongs_to :issue, optional: true
  belongs_to :person

  has_many :funding_seeds
end
