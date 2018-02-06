class Domicile < ApplicationRecord
  belongs_to :issue, optional: true
  belongs_to :person

  has_many :domicile_seeds
end
