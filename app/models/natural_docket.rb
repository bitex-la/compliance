class NaturalDocket < ApplicationRecord
  belongs_to :issue, optional: true
  belongs_to :person

  has_many :natural_docket_seeds
end
