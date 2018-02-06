class LegalEntityDocket < ApplicationRecord
  belongs_to :issue, optional: true
  belongs_to :person

  has_many :legal_entity_docket_seeds
end
