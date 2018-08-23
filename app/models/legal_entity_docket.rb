class LegalEntityDocket < ApplicationRecord
  include Garden::Fruit
  validates :country, country: true

  def self.name_body(i)
    i.commercial_name || i.legal_name
  end
end
