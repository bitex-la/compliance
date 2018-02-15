class Quotum < ApplicationRecord
  belongs_to :issue, optional: true
  belongs_to :person

  has_many :quota_seeds
end
